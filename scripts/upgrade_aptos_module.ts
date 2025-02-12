
import { Account, Aptos, AptosConfig, Ed25519PrivateKey, Network, AccountAddress } from "@aptos-labs/ts-sdk";
import * as fs from "fs";
import * as path from "path";

function setupMovementConfig(): Aptos {
    const config = new AptosConfig({
        network: Network.CUSTOM,
        fullnode: process.env.MOVEMENT_NODE_URL,
        indexer: process.env.MOVEMENT_INDEXER_URL,
    })
    const aptos = new Aptos(config)
    return aptos
}

async function upgradePackage(
    client: Aptos,
    admin: Account,
    module_address: AccountAddress,
    packageMetadata: string,
    moduleFiles: string[]
) {
    // Read and serialize the metadata
    const metadata = fs.readFileSync(packageMetadata);

    // Read and serialize all module bytecodes
    const modules = moduleFiles.map(file => {
        return fs.readFileSync(file);
    });

    // Create and submit transaction
    const transaction = await client.transaction.build.simple({
        sender: admin.accountAddress,
        data: {
            function: `${module_address}::upgrade::upgrade_package`,
            functionArguments: [
                metadata,
                modules
            ]
        },
    });

    const txn = await client.transaction.signAndSubmitTransaction({ signer: admin, transaction });
    console.log("hash", txn.hash)
    const txnResponse = await client.transaction.waitForTransaction({ transactionHash: txn.hash });
    console.log("Package upgraded successfully!");
    console.log("response", txnResponse)
}

async function main() {
    const args = process.argv;
    if (args.length < 4) {
        console.error("Usage: npx ts-node -r dotenv/config run scripts/upgrade_movement.ts <packageName> <address>");
        process.exit(1);
    }

    const module = args[2]
    const packageLocation = `${module}/build/${module}/`;

    const moduleAddressRaw = args[3];

    if (!moduleAddressRaw) {
        console.error("Error: 'result' key not found in addresses.json file");
        process.exit(1);
    }

    const moduleAddress = AccountAddress.fromString(moduleAddressRaw)

    const aptosClient = setupMovementConfig();
    const signerPrivateKey = new Ed25519PrivateKey(process.env.MOVEMENT_USER_PRIVATE_KEY ?? "")
    const signer = Account.fromPrivateKey({ privateKey: signerPrivateKey })
    const metadataFile = packageLocation + "package-metadata.bcs"
    const packageFiles: string[] = []


    fs.readdirSync(packageLocation + "bytecode_modules/", { withFileTypes: true }).forEach(file => {
        if (!file.isDirectory()) {
            packageFiles.push(file.parentPath + file.name)
        }
    });

    await upgradePackage(aptosClient, signer, moduleAddress, metadataFile, packageFiles)
}

main().then(() => console.log("success")).catch((err) => console.error(err))