(function (this)
    local onePage = ert.channel:get_page("epay_prepower_input","EPI1000");
    this.preconFlg = "1" --默认是即时转账
    -- --计算手续费
    --   local  function charge_count()
    --      local PayAccNo = this.accNo;
    --      local RcvAccNo = format_utils.trim(ert("#rcv_acc"):val());
    --      local TranAmt = format_utils.format_undec(ert("#tran_money"):val(),",");
   
    --    local validator = Validator:new()
    --    validator:add("rcv_acc","is_empty_id","请输入收款账号")
    --    validator:add("tran_money","is_empty_id","请输入转账金额")
    --    local error_msg = validator:start()
    --    if error_msg then
    --       alert(error_msg)
    --       return
    --    end
    --      local PayAccOpenNode =  this.accNoOpNode;
    --      local RcvBankCode ;
    --      local OprType ; --行内10 二代 20 超网 30
    --      if this.rcvtype == 0 then
    --       RcvBankCode = this.inner_Bankcode
    --       OprType = "10"
    --      else
    --           validator:add("rcv_bank_val","is_empty_id","请选择收款银行")
    --           if  ert("#branch_info"):css("display") == "none" then
    --           if ert("#open_acc_info"):css("display") ~= "none" then
    --               validator:add("open_acc_val","is_empty_id","请选择开户行")
    --           end
    --           RcvBankCode = this.online_bankcode
    --           OprType = "30"
    --           else
    --           validator:add("rev_city","is_empty_id","请选择收款银行开户地")
    --           validator:add("rev_wangdian","is_empty_id","请选择网点")
    --           RcvBankCode = this.wangdiancode
    --           OprType = "20"
    --           end
    --      end
    --    local error_msg = validator:start()
    --    if error_msg then
    --         alert(error_msg)
    --         return
    --    end
    --      local postbody ={
    --        OprType = OprType,
    --      PayAccNo = PayAccNo,
    --      RcvAccNo = RcvAccNo,
    --      TranAmt = TranAmt,
    --      PayAccOpenNode = PayAccOpenNode,
    --      RcvBankCode = RcvBankCode
    --      }
    --      ebank_utils.just_get_data("transfer_entry","charge_count",function (res)
    --             local data  = res["responseBody"];
    --         local feeAmt = json:objectFromJSON(data).RSP_BODY.feeAmt;
    --         ert("#charge_val"):attr("value",string.format("%.2f",feeAmt))
    --      end,postbody)
    --   end 
    --付款金额格式化
    function money_change()
        local money = format_utils.format_undec(ert("#money"):val(),",")
        ert("#money"):attr("value",format_utils.format_money(money))
    end

    local function getPostBody( ... )
        local preconTime = this.preconFlg == "2" and ert("#payDate"):val() or ""
        local postBody = {
            payAccNo = onePage.wtf_data.dbtrActId,      --付款账号
            payAccName = onePage.wtf_data.dbtrNm,       --付款户名
            payAccNoOpBank = onePage.wtf_data.branchNo, --付款开户行 
            payAccNoOpNode = onePage.wtf_data.openNode, --付款开户网点
            ccyCd = onePage.wtf_data.ccyCd,             --币种
            amount = format_utils.format_undec(ert("#money"):val(),","),  --付款金额
            preconTime = preconTime,
            preconFlg = this.preconFlg,                 --1:不预约 2：预约
            creditBizId = onePage.wtf_data.creditBizId  --预授权业务编号
        }
    end

    local function check( ... )
        check_utils.check_empty("money","请输入付款金额")
        local money = format_utils.format_undec(ert("#money"):val(),",")
        if tonumber(money) > tonumber(onePage.wtf_data.creditAmt) then
            check_utils.alert_error("输入金额不能超过预授权金额")
        end
        check_utils.check_empty("payDate","请选择付款时间")
    end
    --付款码
    local function ercode_fun()
        -- ert.channel:power_show_loading();
        -- local postBody = {
        --     accNo = onePage.wtf_data.dbtrActId,
        --     createFlag = "1",   --0：收款方 1：付款方
        --     rcvBankCode = "",
        --     rcvBankName = "交通银行",
        --     payBranchNo = onePage.wtf_data.branchNo,
        --     payOpenNode = onePage.wtf_data.openNode
        -- };
        -- ebank_utils.just_get_data("epay_prepower_input", "get_token", function (response)
        --     local data = response["responseBody"];
        --     local result = json:objectFromJSON(data).RSP_BODY;
        --     this.token = result.token;
        --     local page_content = ert.channel:get_file("epay_prepower_input","EPI2001.xhtml");
        --     ert.channel:power_hide_loading()
        --     window:showContent(page_content,  ert.channel.loadingtag);
        -- end, postBody, option, true)
        local postBody = getPostBody()
        this.postBody=postBody
        this.epay_page_flag = 1
        ebank_utils.jump_just_page("epay_prepower_input", "EPI3000")
    end
    -- --防重防窜接口
    -- local function prevent_repet_tamper( ... )
    --     local preconTime = preconFlg == "2" and ert("#payDate"):val() or ""
    --     local postBody={
    --             targetCode="MB06707",
    --             token = this.token,
    --             payAccNo = onePage.wtf_data.dbtrActId,
    --             payAccName = onePage.wtf_data.dbtrNm,
    --             payAccNoOpBank = onePage.wtf_data.branchNo,
    --             payAccNoOpNode = onePage.wtf_data.openNode,
    --             rcvAccNo = this.erResT.accNo,
    --             rcvAccName = this.erResT.accName,
    --             rcvAccNoOpBank = this.erResT.rcvBankCode,
    --             amount = format_utils.format_undec(ert("#money"):val(),","),
    --             preconTime = preconTime,
    --             preconFlg = this.preconFlg, --1:不预约 2：预约
    --             creditBizId = onePage.wtf_data.creditBizId
    --     }
    --     this.postBody_repet= postBody
    --     ebank_utils.just_get_data("epay_prepower_input", "EPI5000", function(response)
    --         local data = response["responseBody"];
    --         this.res_body = json:objectFromJSON(data).RSP_BODY;

    --         -- ert.channel:power_hide_loading()
    --         this.is_bluekey = "1"  --0为可使用  1 为不可使用
    --         this.is_massge =  "0"  --0为可使用  1 为不可使用
    --         -- 判断短信是否可用
    --         local money = format_utils.format_undec(ert("#money"):val(),",")
    --         if tonumber(money) > 50000 then
    --             this.is_massge =  "1"
    --         end
    --         -- 判断蓝牙是否可用
    --         if this.res_body.authList ~= "" and this.res_body.authList ~= nil and this.res_body.authList[1].code =="5" then
    --             this.is_bluekey = "0"
    --         end
    --         if tonumber(money) > 50000 and this.is_bluekey == "1" then
    --             alert("请您使用蓝牙KEY办理5万元以上的转账业务")
    --             return
    --         end
    --         ebank_utils.jump_just_page("epay_prepower_input", "EPI5000")
    --     end, postBody)      
    -- end
    --扫一扫的回调事件
    -- function get_ercode_info(aaa)
    --     this.token=tostring(aaa)
    --     ebank_utils.just_get_data("epay_prepower_input", "get_ercodeInfo", function(response)
    --         local data = response["responseBody"];
    --         local table_data = json:objectFromJSON(data);
    --         this.erResT = table_data.RSP_BODY; ---返回二维码中的账号，用户名等信息
    --         if this.erResT.createFlag == "0" then --收款码
    --             prevent_repet_tamper()
    --         else
    --             alert("请扫收款码")
    --         end
    --     end, {token = tostring(aaa)}, option, true)
    -- end

    --扫一扫
    local function scanning_fun()
        check()
        local postBody = getPostBody()
        this.postBody=postBody
        this.epay_page_flag = 2
        ebank_utils.jump_just_page("epay_prepower_input", "EPI3000")
        -- ebank_utils.refresh("code_div", "EPI2002.xml", "epay_prepower_input");
        -- ert("#payAll_div"):css("display","none")
        -- location:reload();
    end
    --无收款人二维码
    local function noErcode_fun()
        check()
        local postBody = getPostBody()
        this.postBody=postBody
        ebank_utils.jump_just_page("epay_prepower_input", "EPI4000")
    end
    --立即转账和预约转账单选
    local function check_style_fun( ... )
        if ert("#noPreTime"):attr("checked") == "true" then
            this.preconFlg = "1"
            ert("#payDate_div"):css("display",'none')
        else
            this.preconFlg = "2"
            ert("#payDate_div"):css("display",'block')
        end
        location:reload()
    end

    local function init( ... )
        ert(".check_style"):click(check_style_fun)
        ert("#ercode_div"):click(ercode_fun)
        ert("#scan_div"):click(function ()
            pcall(scanning_fun)
        end)
        ert("#noErcode_div"):click(function ()
            pcall(noErcode_fun)
        end)
    end

    init()
end)(ert.channel:get_page("epay_prepower_input","EPI2000"));
