// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 

interface Iimplementation {
    function initialise(address manger, IERC20 _stablecoin) external;
}

contract Factory{
    address implementation;
    address owner;
    
    constructor(address _implementation){
        implementation = _implementation;
        owner = msg.sender;
    }

    modifier OnlyOwner(){
        require(msg.sender == owner);
        _;
    }

    event Created(address clone);

    function clone(address _implementation, uint256 _salt, address manger, IERC20 _stablecoin) external OnlyOwner{
        bytes32 salt  = keccak256(abi.encodePacked(block.timestamp, _salt));
        address newClone = Clones.cloneDeterministic(_implementation, salt);
        Iimplementation(newClone).initialise(manger, _stablecoin);
        emit Created(newClone);
    }

}