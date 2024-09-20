// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {TokenReducedFees} from "../src/TokenReducedFees.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

struct poolConfig {
    address tokenAddress;
    address owner;
    uint24 regularFees;
    uint24 reducedFees;
}


contract CounterTest is Test {
    using PoolIdLibrary for PoolKey;

    IPoolManager manager;
    TokenReducedFees hook;
    MockERC20 token0;
    MockERC20 token1;
    MockERC20 tokenForHook;
    PoolKey key;
    PoolId poolId;

    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        // Deploy mock contracts
        manager = IPoolManager(address(new MockPoolManager()));
        token0 = new MockERC20("Token0", "TKN0", 18);
        token1 = new MockERC20("Token1", "TKN1", 18);
        tokenForHook = new MockERC20("HookToken", "HTKN", 18);

        // Deploy the hook
        hook = new TokenReducedFees(manager);

        // Create the pool key
        key = PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, 60, IHooks(address(hook)));
        poolId = key.toId();

        // Initialize the pool
        bytes memory initData = abi.encode(1000, 500, address(tokenForHook)); // regularFees, reducedFees, tokenAddress
        manager.initialize(key, 1 << 96, initData); // sqrt price of 1.0

        // Mint some tokens to Alice and Bob
        token0.mint(alice, 1000e18);
        token1.mint(alice, 1000e18);
        token0.mint(bob, 1000e18);
        token1.mint(bob, 1000e18);

        // Mint some hook tokens to Alice
        tokenForHook.mint(alice, 100e18);
    }

    function testAfterInitialize() public {
        poolConfig memory config = hook.pools(poolId);
        assertEq(config.tokenAddress, address(tokenForHook));
        assertEq(config.owner, address(this));
        assertEq(config.regularFees, 1000);
        assertEq(config.reducedFees, 500);
    }

    function testSetPoolConfig() public {
        hook.setPoolConfig(key, 1500, 750, address(0x123));

        TokenReducedFees memory config = hook.pools(poolId);
        assertEq(config.tokenAddress, address(0x123));
        assertEq(config.regularFees, 1500);
        assertEq(config.reducedFees, 750);
    }

    function testBeforeSwapWithReducedFees() public {
        vm.prank(alice);
        (bytes4 selector, , uint24 fees) = hook.beforeSwap(alice, key, IPoolManager.SwapParams({zeroForOne: true, amountSpecified: 100, sqrtPriceLimitX96: 0}), "");

        assertEq(selector, hook.beforeSwap.selector);
        assertEq(fees, 500); // Should be reduced fees
    }

    function testBeforeSwapWithRegularFees() public {
        vm.prank(bob);
        (bytes4 selector, , uint24 fees) = hook.beforeSwap(bob, key, IPoolManager.SwapParams({zeroForOne: true, amountSpecified: 100, sqrtPriceLimitX96: 0}), "");

        assertEq(selector, hook.beforeSwap.selector);
        assertEq(fees, 1000); // Should be regular fees
    }
}

// Mock contracts

contract MockPoolManager is IPoolManager {
    function initialize(PoolKey calldata key, uint160 sqrtPriceX96, bytes calldata hookData) external {
        // Simulate pool initialization
        TokenReducedFees(address(key.hooks)).afterInitialize(msg.sender, key, sqrtPriceX96, 0, hookData);
    }

    // Implement other required functions...
}

contract MockERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}