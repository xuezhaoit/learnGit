(function (this)

    -- local onePage = ert.channel:get_page("epay_prepower_input","EPI1000");
    local twoPage = ert.channel:get_page("epay_prepower_input","EPI2000");
    --点击“更换”show出账户列表页面
    function show_accountList()
        ebank_utils.just_get_data("epay_prepower_input", "get_payAccList", function(response)
            local data = response["responseBody"];
            local res_body = json:objectFromJSON(data).RSP_BODY;
            this.payAccList=res_body.accNoList
        end, postBody)
        ebank_utils.show_page("epay_prepower_input/xhtml/show_accountList.xhtml")
    end
    --防重防窜接口
    local function prevent_repet_tamper( ... )
        local postBody={
                targetCode="MB06707",
                token = this.token,
                payAccNo = twoPage.postBody.dbtrActId,      --付款账号
                payAccName = twoPage.postBody.dbtrNm,       --付款户名
                payAccNoOpBank = twoPage.postBody.branchNo,     --付款开户行
                payAccNoOpNode = twoPage.postBody.openNode,     --付款开户网点
                rcvAccNo = this.erResT.accNo,
                rcvAccName = this.erResT.accName,
                rcvAccNoOpBank = this.erResT.rcvBankCode,
                amount = twoPage.postBody.amount,           --付款金额
                preconTime = twoPage.postBody.preconTime,   
                preconFlg = twoPage.postBody.preconFlg,     --1:不预约 2：预约
                creditBizId = twoPage.postBody.creditBizId  --预授权业务编号
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

    --防重复提交接口（检查用户是否重复提交）
    local function check_repetitive_event(collectAcc, payAccNo, amount)
        local postBody = {
                rcvAccNo = collectAcc,
                payAccNo = payAccNo,
                amount = amount
            }
        ebank_utils.just_get_data("epay_prepower_input", "get_repetitive_event", function(response)
            local data = response["responseBody"];
            local res_body = json:objectFromJSON(data).RSP_BODY;
            local repeatFlg = res_body.repeatFlg;
            if repeatFlg == "1" then
                ert.channel:power_hide_loading()
                alert("有重复转账，请确认是否继续","确定","取消",
                    function(index)
                        if index == 0 then
                            ert.channel:power_show_loading()
                            prevent_repet_tamper();
                        end
                    end);
            else
                prevent_repet_tamper();
            end
        end, postBody)
    end
    --轮循请求MB06706接口
    local function get_collect_info()
        -- local code = epay_timer1:get("epayPaytoken");
        ert.channel:power_show_loading()
        ebank_utils.just_get_data("epay_prepower_input", "get_collect_info", function (response)
            local data = response["responseBody"];
            local result = json:objectFromJSON(data).RSP_BODY;
            if result.retCode == "1" then
                epay_timer1:stop();
                -- this.result6706 = result;
                local postBodyLimit = {
                    payAccNo = result.payAccNo,
                    amount = result.amount
                }
                ebank_utils.just_get_data("e_pay", "get_limit_amt", function(response)
                    local data = response["responseBody"];
                    local res_head = json:objectFromJSON(data).RSP_HEAD;
                    if res_head.TRAN_SUCCESS == "1" then
                        check_repetitive_event(result.rcvAccNo, result.payAccNo, result.amount);
                    end 
                end, postBodyLimit)
            end
            ert.channel:power_hide_loading()
        end, {token = this.token});
    end

    --付款码
    local function refresh_ercode()
        epay_timer1:stop()
        -- ert.channel:power_show_loading();
        local postBody = {
            accNo = twoPage.postBody.payAccNo,
            createFlag = "1",   --0：收款方 1：付款方
            rcvBankCode = "",
            rcvBankName = "交通银行",
            payBranchNo = twoPage.postBody.payAccNoOpBank,
            payOpenNode = twoPage.postBody.payAccNoOpNode
        };
        ebank_utils.just_get_data("epay_prepower_input", "get_token", function (response)
            local data = response["responseBody"];
            local result = json:objectFromJSON(data).RSP_BODY;
            this.token = result.token;
            -- epay_timer1:set("epayPaytoken", result.token)
            ebank_utils.refresh("code_div", "EPY2002.xml", "epay_prepower_input");
            epay_timer1:start()
            location:reload();
            -- ert.channel:power_hide_loading()
            -- window:showContent(page_content,  ert.channel.loadingtag);
        end, postBody, option, true)  

    end
    ---计时器回调方法
    local function epaytimer1_callback(isStop, time)
        local ctrl = ert("#refresh")
        if not ctrl._has_ctrl then
            return
        end
        if isStop then
            ctrl:attr("enable","true")
            -- 刷新二维码
            refresh_ercode()
        else
            ctrl:attr("enable","false")
            ert("#tips_label"):val(time .. "秒后该付款码失效,自动刷新")
            --每10秒判断
            if (time % 10) == 0 then
                get_collect_info()
            end
        end
        location:reload();
    end
    -- 扫一扫的回调事件
    function get_ercode_info(aaa)
        this.token=tostring(aaa)
        ebank_utils.just_get_data("epay_prepower_input", "get_ercodeInfo", function(response)
            local data = response["responseBody"];
            local table_data = json:objectFromJSON(data);
            this.erResT = table_data.RSP_BODY; ---返回二维码中的账号，用户名等信息
            if this.erResT.createFlag == "0" then --收款码
                prevent_repet_tamper()
            else
                alert("请扫收款码")
            end
        end, {token = tostring(aaa)}, option, true)
    end

    --初始化局
    local function init()
        epay_timer1 = Timer:new("epay_timer1",120, epaytimer1_callback)
        -- epay_timer1:set("epayPaytoken", this.token)
        -- epay_timer1:stop()
        
        if twoPage.epay_page_flag == "1" then
            ert("#code_div"):css("display","block")
            ert("#scan_div"):css("display","none")
            refresh_ercode()
        end
    end

    init();

end)(ert.channel:get_page("epay_prepower_input","EPI3000"));