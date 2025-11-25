debugmode=1
initlogname="fuck.out"
initdatname="dat.txt"
rndseed=0
dir=0 --0:+x 1:+z 2:-x 3:-z
function isMoving()local v=tas.get_ball_velocity()return v and v.square_magnitude>1e-5 end
function notMoving() return not isMoving() end
function TL() tas.press("lshift left") dir=(dir+3)%4 end
function TR() tas.press("lshift right") dir=(dir+1)%4 end
function U(f) if f==0 then return end tas.hold("up",f) end
function D(f) if f==0 then return end tas.hold("down",f) end
function L(f) if f==0 then return end tas.hold("left",f) end
function R(f) if f==0 then return end tas.hold("right",f) end
function W(f) if f==0 then return end tas.wait_ticks(f) end
function UL(f) if f==0 then return end tas.hold("up left",f) end
function UR(f) if f==0 then return end tas.hold("up right",f) end
function DL(f) if f==0 then return end tas.hold("down left",f) end
function DR(f) if f==0 then return end tas.hold("down right",f) end
function PL(p) local tmp=math.random() if tmp<p then L(1) return 1 else W(1) return 0 end end
function PR(p) local tmp=math.random() if tmp<p then R(1) return 1 else W(1) return 0 end end
function PU(p) local tmp=math.random() if tmp<p then U(1) return 1 else W(1) return 0 end end
function PD(p) local tmp=math.random() if tmp<p then D(1) return 1 else W(1) return 0 end end
function GetRndSeed() return tostring(os.time()):reverse():sub(1,8) end
function rndfloat(L,R) if R>L then local tmp=L L=R R=tmp end return L+math.random()*(R-L) end
function fprint(fmtstr,fname)
    if fname==nil then fname=initlogname end
    if debugmode==0 and fname==initlogname then return end
    local file=io.open(fname,"a+")
    file:write(fmtstr) file:close()
end
function fclear(fname)
    if debugmode==0 then return end
    if fname==nil then fname=initlogname end
    local file=io.open(fname,"w")
    file:write("") file:close()
end
function RndPress(f,op,pressval,mode)
    --op=0:LR  op=1:UD 
    --pressval: + => R/D  - => L/U
    --mode: 0:有随机左右/上下 1:无随机左右/上下
    if op==nil then op=0 end
    if pressval==nil then pressval=0 end
    if mode==nil then mode=0 end
    if math.abs(pressval)>f then
        if pressval>0 then pressval=f
        else pressval=-f end
    end
    local lim=(f-math.abs(pressval))//2
    local t
    if lim>=1 then t=math.random(1,lim)
    else t=0 end
    if mode==1 then t=0 end
    local tp={}
    local id={}
    local opt=""
    for i=1,f do tp[i]=0 id[i]=i end
    for i=1,math.abs(pressval) do
        local idx=math.random(1,#id)
        if pressval>0 then tp[id[idx]]=1
        else tp[id[idx]]=-1 end
        table.remove(id,idx)
    end
    for i=1,t do
        local idx=math.random(1,#id)
        -- tas.print("tp[{}]->L",id[idx])
        tp[id[idx]]=-1
        table.remove(id,idx)
    end
    for i=1,t do
        local idx=math.random(1,#id)
        -- tas.print("tp[{}]->R",id[idx])
        tp[id[idx]]=1
        table.remove(id,idx)
    end
    for i=1,f do
        if tp[i]==-1 then 
            if op==0 then L(1) opt=opt.."L"
            elseif op==1 then U(1) opt=opt.."U" end
        elseif tp[i]==1 then 
            if op==0 then R(1) opt=opt.."R"
            elseif op==1 then D(1) opt=opt.."D" end

        else W(1) opt=opt.."W" end
    end
    -- if tas.get_tick()>=skiptoframe then fprint(string.format("**Rndpress(%d~%d),seed=%d,t=%d,pressval=%d,opt=%s\n",tas.get_tick()-f+1,tas.get_tick(),rndseed,t,pressval,opt)) end
    
    -- tas.print("{}:x={},vx={:.3f}",tas.get_tick(),tas.get_ball_position().x,tas.get_ball_velocity().x)
end
function RndPaperSingleRail(f,op,mid,mxdlt) --op=0-->LR L=-,R=+  op=1-->UD U=+,D=-
    -- fprint(string.format("RPSR(%d~%d)\n",tas.get_tick()+1,tas.get_tick()+f))
    function getexp(x)
        if x<0 then return -math.exp(-x)
        elseif x>0 then return math.exp(x)
        else return 1.0 end
    end
    function getsq(x) return x*math.abs(x) end
    function get_force_probability(dlt, v)
        local max_dlt = 0.3   -- 最大允许偏移量（超过此值极易掉落）
        if mxdlt~=nil then max_dlt=mxdlt end
        local max_v = 2.0     -- 最大参考横向速度
        local v_weight = 0.7  -- 速度影响权重
        local dlt_weight = 0.8 -- 偏移量影响权重
        
        -- 计算偏移量影响因子（0~1）
        local dlt_factor = math.min(math.abs(dlt) / max_dlt, 1.0)
        
        -- 计算速度影响因子（0~1）
        local v_factor = math.min(math.abs(v) / max_v, 1.0)
        
        -- 确定综合调整方向
        if dlt < 0 then  -- 向左偏移
            -- 当速度方向与偏移方向相同时增加纠正概率
            local direction_multiplier = (v < 0) and 1.2 or 0.8
            local raw_prob = dlt_weight * dlt_factor + v_weight * v_factor * direction_multiplier
            local prob = math.min(math.max(raw_prob, 0), 1)
            return -prob  -- 负值表示向右受力概率
            
        elseif dlt > 0 then  -- 向右偏移
            -- 当速度方向与偏移方向相同时增加纠正概率
            local direction_multiplier = (v > 0) and 1.2 or 0.8
            local raw_prob = dlt_weight * dlt_factor + v_weight * v_factor * direction_multiplier
            local prob = math.min(math.max(raw_prob, 0), 1)
            return prob   -- 正值表示向左受力概率
            
        else  -- 完美居中
            return 0
        end
    end
    function getval()
        if op==0 then
            local pos=0.0 local v=0.0 --v,dlt:left=-,right=+
            if dir==0 or dir==2 then pos=tas.get_ball_position().z v=tas.get_ball_velocity().z
            elseif dir==1 or dir==3 then pos=tas.get_ball_position().x v=tas.get_ball_velocity().x end
            local dlt=pos-mid
            if dir==0 or dir==3 then v=-v dlt=-dlt end
            -- fprint(string.format("  pos=%.3f,vx=%.3f,dlt=%.3f\n",pos,v,dlt))
            return get_force_probability(dlt,v)
        else 
            local pos=0.0 local v=0.0 --v,dlt:down=-,up=+
            if dir==0 or dir==2 then pos=tas.get_ball_position().x v=tas.get_ball_velocity().x
            elseif dir==1 or dir==3 then pos=tas.get_ball_position().z v=tas.get_ball_velocity().z end
            local dlt=pos-mid
            if dir==2 or dir==3 then v=-v dlt=-dlt end
            -- fprint(string.format("  pos=%.3f,vx=%.3f,dlt=%.3f\n",pos,v,dlt))
            return get_force_probability(dlt,v)
        end
    end
    local opt=""
    function rndpress()
        if op==0 then
            local tmp=math.random(0,2)
            if tmp==0 then W(1) opt=opt.."W"
            elseif tmp==1 then L(1) opt=opt.."L"
            else R(1) opt=opt.."R" end
        else
            local tmp=math.random(0,2)
            if tmp==0 then W(1) opt=opt.."W"
            elseif tmp==1 then U(1) opt=opt.."U"
            else D(1) opt=opt.."D" end
        end
    end
    for i=1,f do
        -- fprint(string.format("%d:\n",tas.get_tick()+1))
        local p=getval()
        if op==0 then
            if p>0 then 
                local tmp=math.random()
                if tmp<p then L(1) opt=opt.."L"
                else rndpress() end
            else
                local tmp=math.random()
                if tmp<-p then R(1) opt=opt.."R"
                else rndpress() end
            end
        else
            if p>0 then 
                local tmp=math.random()
                if tmp<p then D(1) opt=opt.."D"
                else rndpress() end
            else
                local tmp=math.random()
                if tmp<-p then U(1) opt=opt.."U"
                else rndpress() end
            end
        end
        -- fprint(string.format("  p=%.6f  %s\n",p,opt:sub(i,i)))
    end
end
function RndPaperConcaveFloor(f,limL,limR,mode,DIR) --DIR 0:LR 1:UD    mode 0:左右晃 mode 1:走单边
    if DIR==nil then DIR=0 end
    if mode==nil then mode=0 end
    local mid=(limL+limR)/2
    local width=math.abs(limR-limL)
    local postype --0:向左/下 1:向右/上
    local pos local vel
    -- fprint(string.format("RPCF(%d,%.3f,%.3f,%d,%d)\n",f,limL,limR,mode,DIR))
    function getpv()
        if DIR==0 then
            if dir==0 or dir==2 then pos=tas.get_ball_position().z v=tas.get_ball_velocity().z
            elseif dir==1 or dir==3 then pos=tas.get_ball_position().x v=tas.get_ball_velocity().x end
        else
            if dir==0 or dir==2 then pos=tas.get_ball_position().x v=tas.get_ball_velocity().x
            elseif dir==1 or dir==3 then pos=tas.get_ball_position().z v=tas.get_ball_velocity().z end
        end
    end
    getpv()
    if DIR==0 then
        if pos<=mid then postype=1
        else postype=0 end
        if dir==0 or dir==3 then postype=1-postype end
    else
        if pos<=mid then postype=1
        else postype=0 end
        if dir==2 or dir==3 then postype=1-postype end
    end
    if mode==1 then
        if postype==0 then RndPaperSingleRail(f,DIR,limR,0.1)
        else RndPaperSingleRail(f,DIR,limL,0.1) end
        return
    end
    local limdlt=0.4
    local curlim=rndfloat(limdlt,width/2-limdlt)
    local limp
    function getlimp()
        if DIR==0 then
            if postype==0 then
                if dir==0 or dir==3 then limp=mid+curlim
                elseif dir==1 or dir==2 then limp=mid-curlim
                else tas.assert(false) end
            else
                if dir==0 or dir==3 then limp=mid-curlim
                elseif dir==1 or dir==2 then limp=mid+curlim
                else tas.assert(false) end
            end
        else
            if postype==0 then
                if dir==2 or dir==3 then limp=mid+curlim
                elseif dir==0 or dir==1 then limp=mid-curlim
                else tas.assert(false) end
            else
                if dir==2 or dir==3 then limp=mid-curlim
                elseif dir==0 or dir==1 then limp=mid+curlim
                else tas.assert(false) end
            end
        end
    end
    function chk()
        getpv()
        if DIR==0 then
            if postype==0 then
                if dir==0 or dir==3 then return pos>=limp
                elseif dir==1 or dir==2 then return pos<=limp end
            else
                if dir==0 or dir==3 then return pos<=limp
                elseif dir==1 or dir==2 then return pos>=limp end
            end
        else
            if postype==0 then
                if dir==2 or dir==3 then return pos>=limp
                elseif dir==0 or dir==1 then return pos<=limp end
            else
                if dir==2 or dir==3 then return pos<=limp
                elseif dir==0 or dir==1 then return pos>=limp end
            end
        end
        return false
    end
    getlimp()
    for i=1,f do
        if chk() then
            postype=1-postype
            curlim=rndfloat(limdlt,width/2-limdlt)
            getlimp()
            local tmp=math.random(0,2)
            if tmp==0 then W(1)
            elseif tmp==1 then
                if DIR==0 then L(1)
                else D(1) end
            else
                if DIR==0 then R(1)
                else U(1) end
            end
        else
            if postype==0 then
                if DIR==0 then L(1)
                else D(1) end
            else
                if DIR==0 then R(1)
                else U(1) end
            end
        end
    end
end
function RndPaperFlatFloor(f,limL,limR,limpos,DIR) --不同方向分类讨论待补充
	local width=math.abs(limR-limL)
	--8-4:L->+x R->-x
	function calc_stopping_distance(v)
		v=math.abs(v)
		return 0.0151*v*v+0.0097*v+0.0012
	end
	local lim=0.15
	if f>0 then
		for i=1,f do
			local pos=tas.get_ball_position()
			local vel=tas.get_ball_velocity()
			local stp_dis=calc_stopping_distance(vel.x)
			local dltl=math.abs(pos.x-limL)
			local dltr=math.abs(pos.x-limR)
			if vel.x>0 and dltl<=stp_dis+lim then
				-- tas.print("force to R on frame {}",tas.get_tick())
				R(1)
			elseif vel.x<0 and dltr<=stp_dis+lim then
				-- tas.print("force to L on frame {}",tas.get_tick())
				L(1)
			else
				local tmp=math.random(0,2)
				if tmp==0 then W(1)
				elseif tmp==1 then L(1)
				else R(1) end
			end
		end
	else
		if limpos==nil then tas.error("please set limit for ball to stop when f=0") end
		while true do
			local pos=tas.get_ball_position()
			if pos.z<limpos then break end
			local vel=tas.get_ball_velocity()
			local stp_dis=calc_stopping_distance(vel.x)
			local dltl=math.abs(pos.x-limL)
			local dltr=math.abs(pos.x-limR)
			if vel.x>0 and dltl<=stp_dis+lim then
				R(1)
			elseif vel.x<0 and dltr<=stp_dis+lim then
				L(1)
			else
				local tmp=math.random(0,2)
				if tmp==0 then W(1)
				elseif tmp==1 then L(1)
				else R(1) end
			end
		end
	end
end
function main()
    -- local filein=io.open("tmp.txt","r")
    -- tmp=filein:read("n")+1

    
    -- fclear("tmp.txt")
    -- fprint(string.format("%d\n",tmp),"tmp.txt")
end