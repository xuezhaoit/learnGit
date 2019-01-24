(function (this)
    local threePage = ert.channel:get_page("epay_prepower_input","EPI3000");
    local function timer_callback(isStop, time)
        local ctrl = ert("#sent_mess")
        if not ctrl._has_ctrl then
            return
        end
        if isStop then
            ctrl:css("background-color","#0D6DD6")
            ctrl:attr("enable","true")
            ert("#setCode_label"):val("重新发送")
        else
            ctrl:css("background-color","#C0CBD9")
            ctrl:attr("enable","false")
            ert("#setCode_label"):val(time .. "秒后重新发送")
        end
        location:reload()
    end
    
    --发送短信
    ert("#sent_mess"):click(function()
        postBody = {
            phone = ert.static:get("login_info").phoneNo,
            sendFlag = "0",
            accountNo = string.sub(threePage.res_body.rcvAccNo,-4),
            accountAmt = threePage.res_body.amount
        }
        ert("#verifyCode"):attr("enable", "true")
        ebank_utils.just_get_data("epay_prepower_input", "get_massge",function (response)
            epay_timer:start()
            local data = response["responseBody"];
            local table_data = json:objectFromJSON(data);
            local result = table_data["RSP_BODY"];
            ert("#check_number"):val(result.seq);
            ert("#check_number"):css("display",'block')
            location:reload()
        end,postBody)
    end)

    --认证方式的显隐控制
    local function check_style_fun( ... )
        if ert("#message"):attr("checked") == "true" then
            ert("#message_show"):css("display",'block')
            location:reload()
            ert("#sent_mess"):click(function()
                ert("#check_number"):css("display",'block')
            end)
        else
            ert("#message_show"):css("display",'none')
            ert("#check_number"):css("display",'none')
        end
        location:reload()
    end
    
    --校验
    function check( ... )
        check_utils.check_empty("recAccNo","请输入收款人账号")
        check_utils.check_empty("recAccName","请输入收款人账户名")
        check_utils.check_empty("recBranchNo","请输入收款人开户行")
        check_utils.check_empty("recOpenNode","请输入开户网点")
    end

    --没有收款账户
    local function noPayAcc_fun( ... )
        ebank_utils.jump_just_page("epay_prepower_input", "EPI4000")
    end
    --确认支付
    -- local function submit_next( ... )
    --     -- check()
    --     -- local postBody={
    --     --     recAccNo = ert("#recAccNo"):val(),
    --     --     recAccName = ert("#recAccName"):val(),
    --     --     recBranchNo = ert("#recBranchNo"):val(),
    --     --     recOpenNode = ert("#recOpenNode"):val()
    --     -- }
        
    -- end
    local function submit_next()
        local post_body = {
            targetCode = "MB06707",
            token = threePage.postBody_repet.token,
            payAccNo = threePage.postBody_repet.payAccNo,
            payAccName = threePage.postBody_repet.payAccName,
            payAccNoOpBank = threePage.postBody_repet.payAccNoOpBank,
            payAccNoOpNode = threePage.postBody_repet.payAccNoOpNode,
            rcvAccNo = threePage.postBody_repet.rcvAccNo,
            rcvAccName = threePage.postBody_repet.rcvAccName,
            rcvAccNoOpBank = threePage.postBody_repet.rcvAccNoOpBank,
            rcvAccNoOpNode = threePage.postBody_repet.rcvAccNoOpNode,--收款人开户银行名称(网点名称)
            amount = threePage.postBody_repet.amount,
            creditBizId = threePage.postBody_repet.creditBizId,--预授权的业务编号
            preconFlg = threePage.postBody_repet.preconFlg, --预约标志1-不预约，2-预约
            preconTime = threePage.postBody_repet.preconTime,
            imageCode = threePage.res_body.imageCode,
        }

        if this.is_bluekey =="0"  and this.is_massge =="0" then
            if ert("#message"):attr("checked") ~="true" and ert("#bluekey"):attr("checked") ~="true" then
                alert("请选择一种认证方式")
                return
            end
        elseif this.is_bluekey =="1" and this.is_massge =="0" then
            if ert("#message"):attr("checked") ~="true"  then
                alert("请选择一种认证方式")
                return
            end
        elseif this.is_bluekey =="0"  and this.is_massge =="1" then
            if ert("#bluekey"):attr("checked") ~="true"  then
                alert("请选择一种认证方式")
                return
            end
        end
        if ert("#message"):attr("checked") == "true" then
            post_body.messageFlag = "Y"
            if ert("#verifyCode"):val() == "" then
                alert("请输入验证码")
                return
            end
            postBody = {
                mobile = ert.static:get("login_info").phoneNo,
                verifyCode = ert("#verifyCode"):val()
            }
            ebank_utils.just_get_data("epay_prepower_input", "check_verifyCode",function (response)
                local data = response["responseBody"];
                local table_data = json:objectFromJSON(data);
                local result = table_data["RSP_BODY"];
                if result.flag == "1" then
                    -- ebank_utils.jump_next_page("epay_prepower_input", "EPY4000",post_body)
                    ebank_utils.jump_next_page("epay_prepower_input", "EPI6000",post_body)
                    epay_timer:clear()
                end
            end,postBody)
        else
            post_body.messageFlag = "N"
            ebank_utils.key_authentic("epay_prepower_input", "EPI6000", post_body)
        end
    end

    local function init( ... )
        ert(".check_style"):click(check_style_fun)
        ert("#noPayAcc_div"):click(noPayAcc_fun)
        ert("#submit"):click(function ()
            pcall(submit_next)
        end)
        epay_timer = Timer:new("epay_timer",60, timer_callback)
    end

    init()
end)(ert.channel:get_page("epay_prepower_input","EPI5000"));