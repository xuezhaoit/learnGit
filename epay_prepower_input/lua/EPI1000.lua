(function (this)

    -- 初始化瀑布流数据
    local init_params = {
        waterfullId="wtf",
        dataId="retList",
        channelId="epay_prepower_input",
        tranCode="EPI1010",
        AH=tostring(ebank_utils.screen_h()-88),
        IH="1200",
        IHX="1350",
        callback = function (data,args)
            -- if args == "detail" then
            --     -- post_body = {
            --     --     flwNo = data.FlwNo,
            --     --     fcn="2"
            --     -- }
            --     ebank_utils.jump_next_page("epay_prepower_input","EPI2000",post_body)
            --     this.wtf_data = data
            --     ebank_utils.jump_just_page("epay_prepower_input","EPI2000")
            -- end
            local aa = "1"
        end,
        -- path = "epay_prepower_input/wtf/EPI1010",
        path = "epay_prepower_input/wtf/EPI1020",
        postBody={fcn="2"},--fcn 2:查询预授权列表
        -- showAttr={
        --     "BsnCode","Stt","SmtTim","TranAmt","Oprname"
        -- }
    }

    waterfull:init(this, init_params)

end)(ert.channel:get_page("epay_prepower_input","EPI1000"));
