pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/access/Ownable.sol";

contract Wallet is Ownable {
    mapping(address => uint) public balances;
    struct Request {
        uint amount;
        bool approved;
        uint timestamp;
    }
    mapping(address => Request) public requests;

    event Deposit(
        address indexed _from,
        uint _value,
        uint timestamp
    );
    event Withdrawal(
        address indexed _to,
        uint _value,
        uint timestamp
    );
    event Approval(
        address indexed _to,
        uint _value,
        uint timestamp
    );

    constructor() public {
        owner = msg.sender;
    }

    function deposit() public payable {
        require(msg.value > 0, "Invalid deposit amount");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    function requestWithdrawal(uint _amount) public {
        require(_amount > 0, "Invalid withdrawal amount");
        require(_amount <= balances[msg.sender], "Insufficient funds");
        require(
            requests[msg.sender].timestamp == 0 ||
            block.timestamp >= requests[msg.sender].timestamp + 86400,
            "Withdrawal request already made within the last 24 hours"
        );
        requests[msg.sender].amount = _amount;
        requests[msg.sender].timestamp = block.timestamp;
    }

    function approveWithdrawal(address _to) public onlyOwner {
        require(requests[_to].amount > 0, "No pending withdrawal request");
        requests[_to].approved = true;
        emit Approval(_to, requests[_to].amount, block.timestamp);
    }

    function processWithdrawal(address _to) public onlyOwner {
        require(requests[_to].approved, "Withdrawal not approved");
        uint amount = requests[_to].amount;
        balances[_to] -= amount;
        requests[_to].amount = 0;
        requests[_to].approved = false;
        _to.transfer(amount);
        emit Withdrawal(_to, amount, block.timestamp);
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function getBalanceForAddress(address _user) public view onlyOwner returns (uint) {
        return balances[_user];
    }

}
