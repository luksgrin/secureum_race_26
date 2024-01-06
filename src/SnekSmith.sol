// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.21;

import {Create} from "create-util/Create.sol";

/**
 * @dev Error that occurs when deploying a contract has failed.
 * @param emitter The contract that emits the error.
 */
error DeploymentFailed(address emitter);

/**
 * @dev The interface of this cheat code is called `_CheatCodes`,
 * so you can use the `CheatCodes` interface (see here:
 * https://book.getfoundry.sh/cheatcodes/?highlight=CheatCodes#cheatcode-types)
 * in other test files without errors.
 */
// solhint-disable-next-line contract-name-camelcase
interface _CheatCodes {
    function ffi(string[] calldata) external returns (bytes memory);
}

/**
 * @title SnekSmith: multi-case Vyper Contract Deployer
 * @author luksgrin
 * @notice Forked and adjusted accordingly from here:
 * https://github.com/pcaversaccio/snekmate/blob/main/lib/utils/VyperDeployer.sol
 * which was in turn forked and adjusted accordingly from here:
 * https://github.com/0xKitsune/Foundry-Vyper/blob/main/lib/utils/VyperDeployer.sol.
 * @dev The Vyper deployer is a pre-built contract that takes a filename
 * and deploys the corresponding Vyper contract, returning the address
 * that the bytecode was deployed to.
 */
contract SnekSmith is Create {
    address private constant HEVM_ADDRESS =
        address(uint160(uint256(keccak256("hevm cheat code"))));
    address private self = address(this);

    /**
     * @dev Initialises `cheatCodes` in order to use the foreign function interface (ffi)
     * to compile the Vyper contracts.
     */
    _CheatCodes private cheatCodes = _CheatCodes(HEVM_ADDRESS);

    /**
     * @dev Compiles a Vyper contract and returns the address that the contract
     * was deployed to. If the deployment fails, an error is thrown.
     * @param path The directory path of the Vyper contract.
     * For example, the path of "utils" is "src/utils/".
     * @param fileName The file name of the Vyper contract.
     * For example, the file name for "ECDSA.vy" is "ECDSA".
     * @return deployedAddress The address that the contract was deployed to.
     */
    function createContract(
        string memory path,
        string memory fileName
    ) public returns (address) {
 
        /**
         * @dev Compile the Vyper contract and return the bytecode.
         */
        bytes memory bytecode = _compileVyper(path, fileName);

        /**
         * @dev Return the address that the contract was deployed to.
         */
        return _create(bytecode, "", 0);
    }

    /**
     * @dev Compiles a Vyper contract with constructor arguments and
     * returns the address that the contract was deployed to. If the
     * deployment fails, an error is thrown.
     * @param path The directory path of the Vyper contract.
     * For example, the path of "utils" is "src/utils/".
     * @param fileName The file name of the Vyper contract.
     * For example, the file name for "ECDSA.vy" is "ECDSA".
     * @param args The ABI-encoded constructor arguments.
     * @return deployedAddress The address that the contract was deployed to.
     */
    function createContract(
        string memory path,
        string memory fileName,
        bytes memory args
    ) public returns (address) {

        /**
         * @dev Compile the Vyper contract and return the bytecode.
         */
        bytes memory bytecode = _compileVyper(path, fileName);

        /**
         * @dev Return the address that the contract was deployed to.
         */
        return _create(bytecode, args, 0);
    }

    /**
     * @dev Compiles a Vyper contract and returns the address that the contract
     * was deployed to. If the deployment fails, an error is thrown.
     * @param path The directory path of the Vyper contract.
     * For example, the path of "utils" is "src/utils/".
     * @param fileName The file name of the Vyper contract.
     * For example, the file name for "ECDSA.vy" is "ECDSA".
     * @param value The value in wei to send to the new account.
     * @return deployedAddress The address that the contract was deployed to.
     */
    function createContractWithValue(
        string memory path,
        string memory fileName,
        uint256 value
    ) public returns (address) {

        /**
         * @dev Compile the Vyper contract and return the bytecode.
         */
        bytes memory bytecode = _compileVyper(path, fileName);

        /**
         * @dev Return the address that the contract was deployed to.
         */
        return _create(bytecode, "", value);
    }

    /**
     * @dev Compiles a Vyper contract and returns the address that the contract
     * was deployed to. If the deployment fails, an error is thrown.
     * @param path The directory path of the Vyper contract.
     * For example, the path of "utils" is "src/utils/".
     * @param fileName The file name of the Vyper contract.
     * For example, the file name for "ECDSA.vy" is "ECDSA".
     * @param args The ABI-encoded constructor arguments.
     * @param value The value in wei to send to the new account.
     * @return deployedAddress The address that the contract was deployed to.
     */
    function createContractWithValue(
        string memory path,
        string memory fileName,
        bytes memory args,
        uint256 value
    ) public returns (address) {

        /**
         * @dev Compile the Vyper contract and return the bytecode.
         */
        bytes memory bytecode = _compileVyper(path, fileName);

        /**
         * @dev Return the address that the contract was deployed to.
         */
        return _create(bytecode, args, value);
    }

    /**
     * @dev Compiles a Vyper Blueprint contract and returns the address that 
     * the blueprint was deployed to.
     * If the deployment fails, an error is thrown.
     * @param path The directory path of the Vyper contract.
     * For example, the path of "utils" is "src/utils/".
     * @param fileName The file name of the Vyper contract.
     * For example, the file name for "ECDSA.vy" is "ECDSA".
     * @return deployedAddress The address that the contract was deployed to.
     */
    function createBlueprint(
        string memory path,
        string memory fileName
    ) public returns (address) {
 
        /**
         * @dev Compile the Vyper contract and return the bytecode.
         */
        bytes memory bytecode = _compileVyperERC5202Blueprint(path, fileName);

        /**
         * @dev Return the address that the contract was deployed to.
         */
        return _create(bytecode, "", 0);
    }


    /**
     * @dev Compiles a Vyper Blueprint contract and returns the address that 
     * the blueprint was deployed to.
     * If the deployment fails, an error is thrown.
     * @param path The directory path of the Vyper contract.
     * For example, the path of "utils" is "src/utils/".
     * @param fileName The file name of the Vyper contract.
     * For example, the file name for "ECDSA.vy" is "ECDSA".
     * @param args The ABI-encoded constructor arguments.
     * @return deployedAddress The address that the contract was deployed to.
     */
    function createBlueprint(
        string memory path,
        string memory fileName,
        bytes memory args
    ) public returns (address) {

        /**
         * @dev Compile the Vyper contract and return the bytecode.
         */
        bytes memory bytecode = _compileVyperERC5202Blueprint(path, fileName);

        /**
         * @dev Return the address that the contract was deployed to.
         */
        return _create(bytecode, args, 0);
    }

    /**
     * @dev Compiles a Vyper contract and returns the bytecode.
     * @param path The directory path of the Vyper contract.
     * For example, the path of "utils" is "src/utils/".
     * @param fileName The file name of the Vyper contract.
     * For example, the file name for "ECDSA.vy" is "ECDSA".
     * @return bytecode The bytecode of the Vyper contract.
     */
    function _compileVyper(
        string memory path,
        string memory fileName
    ) internal returns (bytes memory bytecode) {
        /**
         * @dev Create a list of strings with the commands necessary
         * to compile Vyper contracts.
         */
        string[] memory cmds = new string[](2);
        cmds[0] = "vyper";
        cmds[1] = string.concat(path, fileName, ".vy");

        /**
         * @dev Compile the Vyper contract and return the bytecode.
         */
        bytecode = cheatCodes.ffi(cmds);
    }

    function _compileVyperERC5202Blueprint(
        string memory path,
        string memory fileName
    ) internal returns (bytes memory bytecode) {
        /**
         * @dev Create a list of strings with the commands necessary
         * to compile Vyper contracts.
         */
        string[] memory cmds = new string[](4);
        cmds[0] = "vyper";
        cmds[1] = "-f";
        cmds[2] = "blueprint_bytecode";
        cmds[3] = string.concat(path, fileName, ".vy");

        /**
         * @dev Compile the Vyper contract and return the bytecode.
         * @notice no need to prepend needed items for Blueprint ERC
         * because of -f blueprint_bytecode option
         */
        bytecode = cheatCodes.ffi(cmds);
    }

    function _create(
        bytes memory _bytecode,
        bytes memory args,
        uint256 value
    ) internal returns (address deployedAddress) {

        bytes memory bytecode;

        /**
         * @dev Check if constructor arguments are provided.
         */
        if (args.length == 0) {

            bytecode = _bytecode;

        } else {

            /**
            * @dev If provided, add the ABI-encoded constructor arguments to the
            * deployment bytecode.
            */
            bytecode = abi.encodePacked(_bytecode, args);

        }

        /**
         * @dev Deploy the bytecode with the `CREATE` instruction.
         */
        deployedAddress = deploy(value, bytecode);

        /**
         * @dev Check that the deployment was successful.
         */
        if (deployedAddress == address(0)) revert DeploymentFailed(self);
    }
}