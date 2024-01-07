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