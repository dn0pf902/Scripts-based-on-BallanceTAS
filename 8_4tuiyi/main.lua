debugmode=1
skiptoframe=1400
initlogname="fuck.txt"
initlogname2="lx.txt"
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
function resetter()
    tas.wait_until(isMoving)
    tas.press("lalt c r")
    W(1)
    tas.press("lalt s")
    W(1)
    tas.press("lalt c")
    W(200)
    tas.wait_until(isMoving)
end
function RndPaperFlatFloor(f,limL,limR,limpos,mode,DIR) --不同方向分类讨论待补充
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
function datupd()
	local dat=io.open(initdatname,"r")
    local cnt=dat:read("n")
    local bestseed=dat:read("n")
    local posy=dat:read("n")
	local flstpx=dat:read("n")
	local flstvx=dat:read("n")
	local flstvy=dat:read("n")
    dat:close()
	if npos.y>posy then
		bestseed=rndseed
		posy=npos.y
		flstpx=lstpos.x
		flstvx=lstvel.x
		flstvy=lstvel.y
	end
	fclear(initdatname)
	fprint(string.format("%d\n%d\n%.3f\n%.3f\n%.3f\n%.3f\n",cnt+1,bestseed,posy,flstpx,flstvx,flstvy),initdatname)
end
function main()
	tas.skip_rendering(skiptoframe)
    tas.wait_until(isMoving)
	tas.key_down("up")
	tas.wait_until(notMoving)
	tas.key_up("up")
	resetter()
	U(65)
	D(20)
	U(92)
	tas.key_down("up")
	rndseed=GetRndSeed()
	math.randomseed(rndseed)
	RndPaperFlatFloor(0,892.966,888.038,-402.720)
	tas.key_down("right")
	tas.wait_until(function()
		local pos=tas.get_ball_position()
		return pos and pos.x<870
	end)
	tas.key_up("right")
	local lstvel=tas.get_ball_velocity()
	tas.wait_until(function()
		local curvel=tas.get_ball_velocity()
		local ret=false
		if curvel.z>lstvel.z+5 or curvel.y>lstvel.y+7 then ret=true end
		lstvel=curvel
		return ret
	end)
	local res=-1
	for i=1,500 do
		local curpos=tas.get_ball_position()
		if curpos.y<6.5 then
			-- tas.print("failed")
			res=0
			break
		end
		if curpos.z<-453 then
			-- tas.print("succeeded")
			res=1
			break
		end
		W(1)
	end
	local filein=io.open(initdatname,"r")
	local sum=filein:read("n")+1
	local cntsuc=filein:read("n")
	local cntfil=filein:read("n")
	if res==-1 then
		tas.print("error")
	elseif res==0 then
		tas.print("failed")
		cntfil=cntfil+1
	elseif res==1 then
		tas.print("succeeded")
		cntsuc=cntsuc+1
	else tas.print("unexpected value of res") end
	fclear(initdatname)
	fprint(string.format("%d\n%d\n%d\n",sum,cntsuc,cntfil),initdatname)
end