(function (this)
    local twoPage = ert.channel:get_page("epay_prepower_input","EPI2000");
    --校验
    function check( ... )
        check_utils.check_empty("recAccNo","请输入收款人账号")
        check_utils.check_empty("recAccName","请输入收款人账户名")
        check_utils.check_empty("rcv_bank_val","请输入收款人开户行")
        -- check_utils.check_empty("recOpenNode","请输入开户网点")
    end

    --没有收款账户
    local function noPayAcc_fun( ... )
        ebank_utils.jump_just_page("epay_prepower_input", "EPI4002")
    end

    --防重防窜接口
    local function prevent_repet_tamper( ... )
        local postBody={
                targetCode="MB06707",
                -- token = this.token,
                payAccNo = twoPage.postBody.dbtrActId,
                payAccName = twoPage.postBody.dbtrNm,
                payAccNoOpBank = twoPage.postBody.branchNo,
                payAccNoOpNode = twoPage.postBody.openNode,
                rcvAccNo = ert("#recAccNo"):val(),
                rcvAccName = ert("#recAccName"):val(),
                rcvAccNoOpBank = this.bank_code,
                amount = twoPage.postBody.amount,
                preconTime = twoPage.postBody.preconTime,
                preconFlg = twoPage.postBody.preconFlg, --1:不预约 2：预约
                creditBizId = twoPage.postBody.creditBizId
        }
        this.postBody_repet= postBody
        ebank_utils.just_get_data("epay_prepower_input", "EPI5000", function(response)
            local data = response["responseBody"];
            this.res_body = json:objectFromJSON(data).RSP_BODY;

            -- ert.channel:power_hide_loading()
            this.is_bluekey = "1"  --0为可使用  1 为不可使用
            this.is_massge =  "0"  --0为可使用  1 为不可使用
            -- 判断短信是否可用
            local money = format_utils.format_undec(ert("#money"):val(),",")
            if tonumber(money) > 50000 then
                this.is_massge =  "1"
            end
            -- 判断蓝牙是否可用
            if this.res_body.authList ~= "" and this.res_body.authList ~= nil and this.res_body.authList[1].code =="5" then
                this.is_bluekey = "0"
            end
            if tonumber(money) > 50000 and this.is_bluekey == "1" then
                alert("请您使用蓝牙KEY办理5万元以上的转账业务")
                return
            end
            ebank_utils.jump_just_page("epay_prepower_input", "EPI5000")
        end, postBody)      
    end

    --确认支付
    local function submit_next( ... )
        check()
        local postBody={
            recAccNo = ert("#recAccNo"):val(),
            recAccName = ert("#recAccName"):val(),
            recBranchNo = this.bank_code,
            recOpenNode = ert("#recOpenNode"):val()
        }
        this.postBody=postBody
        ebank_utils.jump_just_page("epay_prepower_input", "EPI5000")
    end

    --选择银行回调
    function select_bank_callback(click_bank,bank_code,bank_type)
        this.bank_code = bank_code
        this.BankType = bank_type
        this.BankName = click_bank
        ert("#rcv_bank_val"):val(click_bank)
    end

    --获取银行列表
    local function get_bankInfo()
        ert.channel:power_show_loading();
        ebank_utils.just_get_data("epay_prepower_input","get_bankInfo",function( res )
            local data = res["responseBody"];
            this.bankInfoList = json:objectFromJSON(data).RSP_BODY.bankInfoList;
            this.bankInfoList2 = json:objectFromJSON(data).RSP_BODY.bankInfoList2;
            local page_content = ert.channel:get_file("epay_prepower_input","EPI4001.xhtml");
            window:showContent(page_content,  ert.channel.loadingtag);
        end,postbody,nil, false)
    end

    local function init( ... )
        -- ert("#noPayAcc_div"):click(noPayAcc_fun)
        ert("#rcv_bank"):click(get_bankInfo)
        ert("#submit"):click(function ()
            pcall(submit_next)
        end)
    end

    init()
end)(ert.channel:get_page("epay_prepower_input","EPI4000"));
