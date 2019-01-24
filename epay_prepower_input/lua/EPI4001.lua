this_TRE1003 = {};

local function back_fun(  )
     window:hide(ert.channel.loadingtag);
     binding_physical_back();
end

    --热门银行索引
function this_TRE1003.nav_to_hot()
    local list_bank = ert("#list_bank"):get_userdata();
    local code_top = ert("#hot_bank"):get_userdata();
    local top_px = code_top:getStyleByName("top");
    local top = tonumber(string.sub(top_px,1,-3));
    divLocation:setDivLocation(list_bank,top);
    location:reload();
end;

--计算滑动空间需要滑动高度
local function select_bank()
    --侧栏索引滚动控件
    local list_bank = ert("#list_bank"):get_userdata();
    local ctrl_id = "#"..tostring(this_TRE1003.ctrl)
    local code_top = ert(ctrl_id):get_userdata();
    local top_px = code_top:getStyleByName("top");
    local top = tonumber(string.sub(top_px,1,-3));
    divLocation:setDivLocation(list_bank,top+1);
    location:reload();
end

    --字母滑动索引
function this_TRE1003.nav_to(ctrl)
    this_TRE1003.ctrl = ctrl;
    select_bank();
end;

--带回银行字段
function click_bank(click_bank,bank_code,bank_type)
    blur_flag = 1;
    local call_back = this_TRE1003.context;
    back_fun();
    select_bank_callback(click_bank,bank_code,bank_type);
end



--初始化局刷城市数据
local function init()
    -- ert.channel:power_hide_loading()
	ert(".window_hide"):click(back_fun);
    ebank_utils.refresh("list_bank","EPI3001.xml","epay_prepower_input");
    ert.channel:power_hide_loading()
end

init();

window:setPhysicalkeyListener("backspace",back_fun);



