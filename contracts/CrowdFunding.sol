// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//活动状态
enum CampaignState {
    Ongoing,
    Completed,
    Failed,
    Refunded
}

//众筹合约
contract CrowdFunding {
    //定义众筹活动
    struct CampaignInfo {
        uint256 goal; // 目标金额
        uint256 deadline; //时间搓，精确到秒
        CampaignState state;
        string description;
    }

    struct Campaign {
        CampaignInfo info;
        address payable benefitOnwner;
        address[] fundders; //捐款人
        mapping(address => uint256) donationInfo; //捐款信息
        uint256 totalDonation; //总捐款金额-当前进度
    }

    Campaign[] public campaigns;

    //事件
    event GoalFinish(uint campaignId, uint256 totalDonation);

    //开启众筹活动
    function startCampaign(
        uint256 goal,
        uint256 deadline,
        string memory description
    ) public {
        require(goal > 0, "Goal must be greater than 0");
        require(deadline > 3600, "deadline must be greater than 3600");

        campaigns.push();
        Campaign storage newCampaign = campaigns[campaigns.length - 1];
        newCampaign.info = CampaignInfo(
            goal,
            deadline,
            CampaignState.Ongoing,
            description
        );
        newCampaign.benefitOnwner = payable(msg.sender);
        newCampaign.totalDonation = 0;
    }

    //捐赠
    function donate(uint256 _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];

        require(
            campaign.info.state == CampaignState.Ongoing,
            "Campaign is not ongoing"
        );

        require(
            block.timestamp <= campaign.info.deadline,
            "Campaign deadline has passed"
        );

        //设置捐赠人
        if (campaign.donationInfo[msg.sender] == 0) {
            //如果没找到捐赠人
            campaign.donationInfo[msg.sender] = msg.value;
            campaign.fundders.push(msg.sender);
        } else {
            campaign.donationInfo[msg.sender] += msg.value;
        }

        //更新总捐款金额
        campaign.totalDonation += msg.value;

        //判断当次捐款是否超额
        if (campaign.totalDonation > campaign.info.goal) {
            //变更状态为已完成
            campaign.info.state = CampaignState.Completed;
            emit GoalFinish(_campaignId, campaign.totalDonation);
        }
    }

    //(提前和不提前都是一致的操作)关闭众筹活动，款项归集到受益人账户
    function closeCampaign(uint _campaignId) public returns(bool) {
        //判断是否是onwer发起的退款

        require(
            campaigns[_campaignId].benefitOnwner == msg.sender,
            "Only the owner can close the campaign"
        );

        //判断是否是已完成状态
        //判断是否是退款状态

        require(
            campaigns[_campaignId].info.state != CampaignState.Completed ||
                campaigns[_campaignId].info.state != CampaignState.Refunded,
            "Campaign is completed or refund"
        );

       require(campaigns[_campaignId].totalDonation > 0, "No fund to withdraw");
 
        //更新状态
        campaigns[_campaignId].info.state = CampaignState.Refunded;

        //退款
      (bool result, bytes memory data) = payable(msg.sender).call{value:campaigns[_campaignId].totalDonation}("");
      
       return result;

    }


    //受益人提取资金
    function withdraw(uint _campaignId) public returns(bool) {
        //判断是否是onwer发起的退款
     require(
            campaigns[_campaignId].benefitOnwner == msg.sender,
            "Only the owner can close the campaign"
        );

       require(campaigns[_campaignId].totalDonation > 0, "No fund to withdraw");

        //判断是否是已完成状态，必须是已经完成才能够退款
       require(
            campaigns[_campaignId].info.state == CampaignState.Completed,
            "Campaign is completed or refund"
        );
         
        //更新状态
        campaigns[_campaignId].info.state = CampaignState.Refunded;

        //退款
      (bool result, bytes memory data) = payable(msg.sender).call{value:campaigns[_campaignId].totalDonation}("");

        return result;
    }

    //受益人发起退款

    //获取所有众筹信息
    function getCampaigns() public view returns (CampaignInfo[] memory) {
        CampaignInfo[] memory _cmpaignInfos = new CampaignInfo[](
            campaigns.length
        );

        for (uint i = 0; i < campaigns.length; i++) {
            _cmpaignInfos[i] = campaigns[i].info;
        }

        return _cmpaignInfos;
    }
}
