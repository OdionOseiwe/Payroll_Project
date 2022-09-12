// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

interface IERC20 { 
    function transferFrom(
        address from,
        address to,
        uint256 amountoftoken
    ) external returns(bool);

    function transfer(address to, uint256 amount) external returns (bool) ;
    function balanceOf(address account) external returns (uint256);
} 

    /// @title Payroll system
    /// @author OdionOseiwe

contract Payroll{
    /// @dev a payroll system that a set of address are whitelisted for payout
    /// @dev conditions for withdraw are you can only withdraw once in 30days
    /// @dev you should be whitelisted
    /// @dev the payment is ERC20 tokens(stablecoin)
    /// @dev and ADDITIONAL  create a factory contract with minimial proxy to deploy clones


    /////////////////////////////////////////////////////////PUBLIC VARIALES////////////////////////////////////////////////////////

    address manger;
    uint256 public constant Monthcount = 30 days;
    uint MonthlySalaryForJuniors = 10; 
    IERC20 stablecoin;
    bytes32 rootHash = 0x0d5fb2c7e11ece5346872fad03e984941fb66bd99152d8efb560455fbcde0363;
    uint256 currentAmountofTokens;
    bool intialState;
  
    /////////////////////////////////////////////////////////MAPPING///////////////////////////////////////////////////////////////
    mapping(address => uint256) public Nextwithdrawal;

    //////////////////////////////////////////////////////////EVENTS//////////////////////////////////////////////////////////

    event deposited(address depositor, uint amountoftoken);
    event withdrawed(address worker, uint amountoftoken, uint nextwithdrawal);

    ////////////////////////////////////////////////////////////CUSTOM ERRORS/////////////////////////////////////////////////
    
    /// amount zero not allowed to be deposited
    error Zeroamount();

    /// not whitelisted
    error NotWhitelisted();

    /// try again later insufficient funds
    error InsufficientFunds();

    /// wait try again later in some days
    error  NotTime();

    /// not owner
    error Onlyowner();

    ///////////////////////////////////////////////////////////MODIFIERS///////////////////////////////////////////////////////

    modifier Initialised {
        require(intialState == false, "already initialised");
        _;
    }

    /// @dev the function deposite allows anyone to call it and deposite an amount of tokens
    /// @param amount takes in the amount of tokens to be deposited
    function deposite(uint amount) external{
        if(amount > 0){
           revert Zeroamount();
        } 
        bool sent = stablecoin.transferFrom(msg.sender, address(this), amount);
        require(sent, "failed");
        currentAmountofTokens = currentAmountofTokens + amount;
        emit  deposited(msg.sender, amount);
    }

    function verified(bytes32[] memory proof) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(proof, rootHash, leaf);
    }

    /// @dev function to withdraw after being verified
    /// @param proof an array of proof for a particular person
    function withdraw(bytes32[] memory proof) external {
        bool prove = verified(proof);
        if (prove) {
            revert NotWhitelisted();
        }
        if(block.timestamp > Nextwithdrawal[msg.sender]){
            revert NotTime();
        }
        if (currentAmountofTokens < MonthlySalaryForJuniors) {
            revert InsufficientFunds();
        }
        bool sent = stablecoin.transfer(msg.sender, MonthlySalaryForJuniors);
        require(sent, "failed");
        currentAmountofTokens = currentAmountofTokens - MonthlySalaryForJuniors;
        uint nextmonth = block.timestamp + Monthcount;
        Nextwithdrawal[msg.sender] = nextmonth;
        emit  withdrawed(msg.sender, MonthlySalaryForJuniors, Nextwithdrawal[msg.sender]);
    }

    function updateTokenAddress(IERC20 _stablecoin) external{
        if (msg.sender != manger) {
            revert Onlyowner();
        }
        stablecoin = _stablecoin;
    }

    function updatemanger(address _manger) external{
        if (msg.sender != manger) {
            revert Onlyowner();
        } 
        manger = _manger;
    }

    ////////////////////////////////////////////////////////////CONSTRUCTOR/////////////////////////////////////////////////////////////

    function initialise(address _manger,IERC20 _stablecoin) external Initialised{
        stablecoin = _stablecoin;
        manger = _manger;
        intialState = true;
    }

}  


//  manger = _manger;
