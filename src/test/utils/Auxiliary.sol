// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {EntryPoint} from "@aa/core/EntryPoint.sol";
import "../../contracts/account/IRhinestone4337.sol";
import {PluginManager} from "../../contracts/account/core/PluginManagerSingleton.sol";
import "../../contracts/auxiliary/interfaces/IBootstrap.sol";
import "../../contracts/safe/Bootstrap.sol";
import "../../contracts/auxiliary/interfaces/IProtocolFactory.sol";
import "../../contracts/auxiliary/interfaces/IRegistry.sol";
import "../../contracts/modules/validators//IValidatorModule.sol";
import "../../contracts/modules/recovery/IRecoveryModule.sol";

import {MockValidator} from "../mocks/MockValidator.sol";
import {MockRecovery} from "../mocks/MockRecovery.sol";
import {MockRegistry} from "../mocks/MockRegistry.sol";
import {MockProtocol} from "../mocks/MockProtocol.sol";

struct Auxiliary {
    EntryPoint entrypoint;
    IRhinestone4337 rhinestoneManager;
    PluginManager pluginManager;
    IBootstrap rhinestoneBootstrap;
    IProtocolFactory rhinestoneFactory;
    IValidatorModule validator;
    IRecoveryModule recovery;
    IRegistry registry;
}

contract AuxiliaryFactory {
    EntryPoint internal entrypoint;

    MockValidator internal mockValidator;
    MockRecovery internal mockRecovery;
    MockRegistry internal mockRegistry;
    MockProtocol internal mockRhinestoneFactory;
    PluginManager internal pluginManager;

    Bootstrap internal bootstrap;

    address defaultAttester;

    function init() internal virtual {
        defaultAttester = address(0x4242424242);
        bootstrap = new Bootstrap();

        entrypoint = new EntryPoint();
        mockValidator = new MockValidator();
        mockRecovery = new MockRecovery();
        mockRegistry = new MockRegistry();
        mockRhinestoneFactory = new MockProtocol();
    }

    function makeAuxiliary(IRhinestone4337 _rhinestoneManger, IBootstrap _bootstrap)
        internal
        view
        returns (Auxiliary memory aux)
    {
        aux = Auxiliary({
            entrypoint: entrypoint,
            rhinestoneManager: _rhinestoneManger,
            pluginManager: pluginManager,
            rhinestoneBootstrap: _bootstrap,
            rhinestoneFactory: mockRhinestoneFactory,
            validator: mockValidator,
            recovery: mockRecovery,
            registry: mockRegistry
        });
    }
}

library AuxiliaryLib {
    function getModuleCloneAddress(Auxiliary memory env, address implementationToClone, bytes32 salt)
        internal
        view
        returns (address)
    {
        MockProtocol factory = MockProtocol(address(env.rhinestoneFactory));

        return factory.getClone(implementationToClone, salt);
    }

    function deployModuleClone(Auxiliary memory env, address implementationToClone, bytes32 salt)
        internal
        returns (address)
    {
        MockProtocol factory = MockProtocol(address(env.rhinestoneFactory));
        return factory.clonePlugin(implementationToClone, salt);
    }
}
