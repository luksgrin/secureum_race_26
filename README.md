# Secureum RACE 26

# [Q1] Given the following Vyper contract, which of the following statements are true?

```python
# @version 0.3.0

"""A simple vault contract

This contract implements a simple vault where users can deposit and withdraw
ether.
"""

userBalances: public(HashMap[address, uint256])

event Deposit:
    src: indexed(address)
    amount: uint256

event Transfer:
    src: indexed(address)
    dst: indexed(address)
    amount: uint256

event Withdrawal:
    src: indexed(address)
    amount: uint256

@external
@payable
def deposit():
    self.userBalances[msg.sender] += msg.value
    log Deposit(msg.sender, msg.value)

@external
@nonreentrant("withdraw")
def transfer(to: address, amount: uint256):
    if self.userBalances[msg.sender] >= amount:
        self.userBalances[msg.sender] -= amount
        self.userBalances[to] += amount
        log Transfer(msg.sender, to, amount)

@external
@nonreentrant("withdraw")
def withdrawAll():
    _balance: uint256 = self.userBalances[msg.sender]
    assert _balance > 0, "Insufficient balance"

    raw_call(msg.sender, b"", value=_balance)

    self.userBalances[msg.sender] = 0
    log Withdrawal(msg.sender, _balance)

@external
@view
def getBalance() -> uint256:
    return self.balance
```

- (A) The contract is vulnerable to reentrancy attacks
- (B) The contract is vulnerable to denial of service attacks
- (C) The contract is vulnerable to overflow attacks
- (D) None of the above

**Solution**: A

The contract is vulnerable to reentrancy attacks, in particular, cross-function re-entrancy (between `transfer` and `withdrawAll`).
Although the contract uses the `nonreentrant` decorator with the key `"withdraw"`, given that the vyper version is 0.3.0, the lock does not protect against cross-function re-entrancy. See https://github.com/vyperlang/vyper/security/advisories/GHSA-5824-cm3x-3c38

# [Q2] Given the following Vyper contract, which of the following statements are true?

```python
# @version 0.3.7

"""A small vault implementation

This contract implements a simple vault where users can deposit and withdraw
ether, where the balances of each user are stored in a custom hashmap implementation to lower the number of users that can use the vault.
"""

MAX_USERS: constant(uint256) = 2**64 + 1
_balances: uint256[MAX_USERS]
admin: public(address)

event AdminSet:
    admin: indexed(address)

event Deposit:
    src: indexed(address)
    amount: uint256

event Transfer:
    src: indexed(address)
    dst: indexed(address)
    amount: uint256

event Withdrawal:
    src: indexed(address)
    amount: uint256

@external
def __init__():
    self._set_admin(msg.sender)

@internal
def _indexer(_address: address) -> uint256:
    return convert(keccak256(convert(_address, bytes32)), uint256) % MAX_USERS

@internal
def _is_admin(_address: address) -> bool:
    return _address == self.admin

@internal
def _set_admin(_admin: address):
    self.admin = _admin
    log AdminSet(_admin) 

@external
def setAdmin(_admin: address):
    assert self._is_admin(msg.sender), "Only admin can set admin"
    self._set_admin(_admin)

@external
def userBalances(_address: address) -> uint256:
    return self._balances[self._indexer(msg.sender)]

@external
@payable
def deposit():
    self._balances[self._indexer(msg.sender)] = msg.value
    log Deposit(msg.sender, msg.value)

@external
def transfer(to: address, amount: uint256):
    if self._balances[self._indexer(msg.sender)] >= amount:
        self._balances[self._indexer(msg.sender)] -= amount
        self._balances[self._indexer(to)] += amount
        log Transfer(msg.sender, to, amount)

@external
def withdrawAll():
    _balance: uint256 = self._balances[self._indexer(msg.sender)]
    assert _balance > 0, "Insufficient balance"

    self._balances[self._indexer(msg.sender)] = 0
    raw_call(msg.sender, b"", value=_balance)
    
    log Withdrawal(msg.sender, _balance)

@external
@view
def getBalance() -> uint256:
    return self.balance

@external
def kill():
    assert self._is_admin(msg.sender), "Only admin can kill"
    selfdestruct(msg.sender)
```

- (A) The reentrancy locks are not necessary
- (B) The reentrancy locks do not protect against cross-function re-entrancy
- (C) Collisions in the `_balances` array can occur in theory, but are unlikely to occur in practice
- (D) Collisions in the `_balances` array can occur both in theory and in practice

**Solutions**: A, C

For A, the reentrancy locks could be safely removed because the functions follow the Checks-Effects-Interactions pattern.
B is false because the reentrancy locks in this vyper version work properly.
C is true. The proof is:

Let $N$ be the total possible indexes in our array ($2^{64} + 1$). Using the birthday paradox, the probability of a collision after using $k$ different addresses is $P(k) = 1 - e^{-\frac{k\cdot (k - 1)}{2 \cdot (2^{64} + 1)}}$.

To have a $50\%$ chance of collision, we must solve for $k$ in $0.5 = 1 - e^{-\frac{k\cdot (k - 1)}{2 \cdot (2^{64} + 1)}}$, which has a solution $k\approx 5056940000$, which implies that to have a $50%$ chance of collisions to occur, more than half of the entire planet must have an ethereum address and have interacted with the contract.

So, in practice, impossible.

D is false because (see above).

# [Q3] Given the same Vyper contract as in Q2, select the true statement(s).

- (A) A malicious admin can steal all the funds in the contract
- (B) Anyone can hijack the admin in theory, but it is highly unlikely to happen in practice
- (C) Anyone can hijack the admin both in theory and in practice
- (D) None of the above

**Solution**: A, B

A is true because the admin can call `kill` and steal all the funds in the contract. B is true because the probability of a collision is very low (see Q2), but in theory one could call the contract from an address whose index (given by `_indexer`) is $2^{64}$, so the balance written there would break the contract (see https://github.com/vyperlang/vyper/security/advisories/GHSA-6m97-7527-mh74), but doing that in practice is impossible.

C is false due to the above reason. D is false because A and B are true.

# [Q4] What would be the Solidity equivalent of the `_indexer` function?

- (A): `function _indexer(address _address) private pure returns (uint256) { return uint256(sha256(abi.encodePacked(_address))) % MAX_USERS; }`

- (B): `function _indexer(address _address) internal view returns (uint256) { return uint256(sha256(abi.encode(_address))) % MAX_USERS; }`

- (C): `function _indexer(address _address) internal returns (uint256) { return uint256(sha256(abi.encodePacked(_address))) % MAX_USERS; }`

- (D): `function _indexer(address _address) internal returns (uint256) { return uint256(sha256(abi.encode(_address))) % MAX_USERS; }`


**Solution**: D

# [Q5] Which function would be more suitable to deploy a gnosis safe module?

- (A) `create_minimal_proxy_to`
- (B) `create_copy_of`
- (C) `create_from_blueprint`
- (D) None of the above

**Solution**: A. Gnosis modules follow EIP 1167, which is what `create_minimal_proxy_to` implements. The other two functions copy runtime code, which is not what we want [see https://github.com/gnosis/module-factory]

# [Q6] Given the functions below, which of the following statements are false?

```python
# @version 0.3.7

@external
@pure
def unsafeSum(a: uint256, b: uint256) -> uint256:
    return unsafe_add(a, b)

@external
def weird1(a: uint256, b: uint256) -> uint256:
    return _abi_decode(
        raw_call(
            self,
            _abi_encode(
                (a, b),
                method_id=method_id("unsafeSum(uint256,uint256)")
            ),
            max_outsize=32
        ),
        uint256
    )

@external
def weird2(a: uint256, b: uint256) -> uint256:
    return _abi_decode(
        raw_call(
            self,
            _abi_encode((
                keccak256("unsafeSum(uint256,uint256)"),
                a,
                b
            )),
            max_outsize=32
        ),
        uint256
    )

@external
def weird3(a: uint256, b: uint256) -> uint256:
    return _abi_decode(
        raw_call(
            self,
            _abi_encode((
                0x4f388eb1,
                a,
                b
            )),
            max_outsize=32
        ),
        uint256
    )

@external
def weird4(a: uint256, b: uint256) -> uint256:
    return _abi_decode(
        raw_call(
            self,
            _abi_encode(
                (a, b),
                method_id=0x4f388eb1
            ),
            max_outsize=32
        ),
        uint256
    )
```

- (A) This contract cannot be compiled as it calls an external function from another external function
- (B) `weird1` and `weird3` are equivalent
- (C) `weird2` and `weird3` will always fail
- (D) `weird1` and `weird4` are equivalent

**Solution**: A, B, C

A is false because the contract compiles.
B is false because `weird3` does not encode the function signature correctly.
C is false because `weird2` and `weird3`, although they do not correctly call `unsafeSum`, they do not fail.
D is true because `weird1` and `weird4` encode the function signature correctly in 2 different ways.

# [Q7] Under which circumstances does the following function return `True`?

```python
# @version 0.3.7

@external
def fun(a: uint256, b: uint256) -> bool:
    return sqrt(a) == isqrt(b)
```

- (A) When `a == b`
- (B) When neither `a` nor `b` are perfect squares
- (C) When `a + b < 1 + 2*sqrt(a*b)`
- (D) None of the above

**Solution**: D. This does not even compile because `sqrt` works with the `decimals` type while `isqrt` works with `uint256`.

# [Q8] Given the following broken Vyper contract, what changes are necessary so that the source code can be successfully compiled?

```python

# @version 0.3.7

from vyper.interfaces import ERC20

implements: ERC20

balances: public(HashMap[address, uint256])
allowed: public(HashMap[address, HashMap[address, uint256]])
total_supply: public(uint256)

event Transfer:
    from: indexed(address)
    to: indexed(address)
    value: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

@external
def __init__(_initial_supply: uint256):
    self.total_supply = _initial_supply

@internal
def _mint(to: address, value: uint256):
    assert self.total_supply + value > self.total_supply
    assert self.balances[to] + value > self.balances[to]

    self.total_supply += value
    self.balances[to] += value

    log Transfer(empty(address), to, value)

@external
def allowance(owner: address, spender: address):
    pass

@external
def approve(spender: address, value: uint256):
    pass

@external
def balanceOf(owner: address) -> uint256:
    return self.balances[owner]

@external
def transfer(to: address, value: uint256) -> bool:
    assert self.balances[msg.sender] >= value
    assert self.balances[_to] + value >= self.balances[to]

    self.balances[msg.sender] -= value
    self.balances[to] += value

    log Transfer(msg.sender, to, value)

    return True

@external
def transferFrom(from: address, to: address, value: uint256) -> bool:
    assert self.balances[from] >= value
    assert self.balances[to] + value >= self.balances[to]
    assert self.allowed[from][msg.sender] >= value

    self.balances[to] += value
    self.balances[from] -= value
    self.allowed[from][msg.sender] -= value

    log Transfer(from, to, value)

    return True

@external
@payable
def __default__():
    self._mint(msg.sender, msg.value)

```

- (A) Replace all instances of `value` and `from` because they are reserved keywords.
- (B) Implement the `allowance` and `approve` functions as this is required by the ERC20 interface
- (C) Implement a `totalSupply` function and rename the `value` field in the `Transfer` event to `_value` as this is required by the ERC20 interface
- (D) None of the above

**Solution**: A and C.
B is false because the ERC20 interface does not require the `allowance` and `approve` functions to be implemented, it just needs them to be declared.
D is false because A and C are true.