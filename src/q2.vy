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
    return convert(sha256(convert(_address, bytes32)), uint256) % MAX_USERS

@external
def indexer(_address: address) -> uint256:
    return self._indexer(_address)

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
@nonreentrant("withdraw")
def transfer(to: address, amount: uint256):
    if self._balances[self._indexer(msg.sender)] >= amount:
        self._balances[self._indexer(msg.sender)] -= amount
        self._balances[self._indexer(to)] += amount
        log Transfer(msg.sender, to, amount)

@external
@nonreentrant("withdraw")
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