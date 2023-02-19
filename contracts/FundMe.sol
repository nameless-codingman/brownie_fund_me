// SPDX-License-Identifier: MIT

//^0.8.17 或者  >=0.6.0<=0.9.0
pragma solidity ^0.8.17;
// 引入的这个合约 并且可以使用他的一些特性 npm  package
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

// interface AggregatorV3Interface {
//   function decimals() external view returns (uint8);

//   function description() external view returns (string memory);

//   function version() external view returns (uint256);

//   function getRoundData(uint80 _roundId)
//     external
//     view
//     returns (
//       uint80 roundId,
//       int256 answer,
//       uint256 startedAt,
//       uint256 updatedAt,
//       uint80 answeredInRound
//     );

//   function latestRoundData()
//     external
//     view
//     returns (
//       uint80 roundId,
//       int256 answer,
//       uint256 startedAt,
//       uint256 updatedAt,
//       uint80 answeredInRound
//     );
// }

contract FundMe {
    // using SafeMathChainlink for uint256;

    //设置一个映射
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    //构造函数赋值  在合约部署的时候立即执行
    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    //这是给钱的代码  捐款的代码
    function fund() public payable {
        uint256 mimimumUSD = 50 * 10 * 18;
        require(
            getConversionRate(msg.value) >= mimimumUSD,
            "You nedd more money!"
        );
        //映射我的地址 对应的 账户价值 msg就是一个对象 代表发送消息里面的 地址和数字
        // 谁谁谁 发了 一共发了多少钱
        addressToAmountFunded[msg.sender] += msg.value;
        //每当一个人调用了找个地址我们就将他的地址存入进去
        funders.push(msg.sender);
    }

    //关键字  modifier 被用于最多的是行为检查  加在函数前面表示 是否满足这个函数的执行条件，相当于是 java springboot的切片
    // _ 代表函数体 就相当于是 withdraw 这个方法 在 modifier中的位置
    //使代码变得更加简洁
    modifier onlyOwner() {
        require(msg.sender == owner, "is not parpose account");
        _;
    }

    // 这个是转钱的代码  取消合同的时候 还原一切
    function withdraw() public payable onlyOwner {
        // require( msg.sender == owner,"is not parpose account"); //先判断，如果不是对应的地址就会直接拒绝这个请求
        // 0.6 版本的取款方法
        // msg.sender.address.transfer(address(this).balance);
        //0.8版本以上的取款方法
        payable(msg.sender).transfer(address(this).balance);
        //完成转账后将余额都清零
        for (uint256 fundIndex = 0; fundIndex < funders.length; fundIndex++) {
            address funder = funders[fundIndex];
            addressToAmountFunded[funder] = 0; //通过映射将其值 设置为0
        }
        // 清空数组
        funders = new address[](0);
    }

    function getVersion() public view returns (uint256) {
        return uint256(priceFeedVersion.version());
    }

    function getPrice() public view returns (uint256) {
        //如果返回的是多个对象就可以用对象列表进行接收
        // (
        //     uint80 roundId,
        //     int256 answer,
        //     uint256 startedAt,
        //     uint256 updatedAt,
        //     uint80 answeredInRound
        // )=
        // priceFeedVersion.latestRoundData();

        //简略的写法就是
        (, int256 answer, , , ) = priceFeedVersion.latestRoundData();

        //强转数据类型
        return uint256(answer * 10000000000);
    }

    //151802000000 返回的结果有 8个小数 转换一下就是 1518.02000000

    //写一个以太币转换美元的代码
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1000000000000000000;
        return ethAmountInUsd;
    }
}
