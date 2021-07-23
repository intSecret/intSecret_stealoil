//
//		Power by intSecret
//

#include <YSI_Coding\y_hooks>
#include <YSI_Coding\y_timers>

new Float:posRobOil[4][3] = {
	{ 201.2866,1411.5200,10.5859 },
	{ 223.3539,1372.1515,10.5859 },
	{ 485.3604,1525.8712,1.4533 },
    { 604.6671,1494.1893,9.0578 }
};

static 
    countTime[MAX_PLAYERS],
    delayOilTime[MAX_PLAYERS],
    bool:statusRobOil[MAX_PLAYERS char],
    Timer:roboilsTime[MAX_PLAYERS];

hook OnPlayerConnect(playerid){

    countTime[playerid] = 0;
    delayOilTime[playerid] = 0;
    statusRobOil{playerid} = false;
    return 1;
}
hook OnGameModeInit(){
    for(new i = 0; i < sizeof(posRobOil); i ++){
        CreateDynamic3DTextLabel("[ขโมยน้ำมัน]\nคำสั่ง '/stealoil' เพื่อขโมย", COLOR_YELLOW, posRobOil[i][0], posRobOil[i][1], posRobOil[i][2], 3.0); //
	    CreateDynamicPickup(3082, 23, posRobOil[i][0], posRobOil[i][1], posRobOil[i][2]);
    }
    
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if ((newkeys & KEY_FIRE) && !(oldkeys & KEY_FIRE))
	{
        if(statusRobOil{playerid} == true)
        {
            ClearAnimations(playerid);
            stop roboilsTime[playerid];
            StopProgress(playerid);
            RemovePlayerAttachedObject(playerid, 9);
            TogglePlayerControllable(playerid, 1);
            statusRobOil{playerid} = false;
            countTime[playerid] = 0;
            delayOilTime[playerid] = 60;

            InfoMsg(playerid, "คุณได้ยกเลิกการขโมยน้ำมันดิบแล้ว.");
        }
    }
    return 1;
}

alias:stealoil("ขโมยน้ำมัน")
CMD:stealoil(playerid){

    for(new i = 0; i < sizeof(posRobOil); i ++) 
    {
        if (IsPlayerInRangeOfPoint(playerid, 3.0, posRobOil[i][0], posRobOil[i][1], posRobOil[i][2]))
        {
            if(GetFactionOnline(FACTION_POLICE) < 1) return ErrorMsg(playerid, "ขณะนี้ไม่มีเจ้าหน้าที่ตำรวจออนไลน์ ไม่สามารถทำได้ในเวลานี้..");

            if(GetPlayerWantedLevelEx(playerid) > 0) return ErrorMsg(playerid, "คุณจะต้องไม่ติดดาว!!");

            if(delayOilTime[playerid] > 0)
                return ErrorMsg(playerid, " โปรดรออีกซักครู่ถึงจะเริ่มขโมยได้อีกครั้ง (%d วินาที)", delayOilTime[playerid]);

            if(statusRobOil{playerid} == true)
                return ErrorMsg(playerid, " คุณกำลังขโมยอยู่..");

            if(statusRobOil{playerid} == false){
                InfoMsg(playerid, "กำลังเริ่มต้นขโมยน้ำมัน...");
                TogglePlayerControllable(playerid, 0);
                SetPlayerAttachedObject(playerid, 9, 1650, 6);
                stop roboilsTime[playerid];
                statusRobOil{playerid} = true;
                countTime[playerid] = 0;
                GameTextForPlayer(playerid, "Robbing ~g~Oil", 5000, 4);
                ApplyAnimation(playerid, "BAR", "BARSERVE_BOTTLE", 4.1, false, false, false, false, 0, false); // rob oil
                roboilsTime[playerid] = repeat oilStealTimmer[4000](playerid);
                StartProgress(playerid, 360, 0);
            }
        }
    }
    return 1;
}

timer oilStealTimmer[1000](playerid)
{
	countTime[playerid]++;

    ApplyAnimation(playerid, "BAR", "BARSERVE_BOTTLE", 4.1, false, false, false, false, 0, false);

    if(statusRobOil{playerid} == true && countTime[playerid] >= 9)
	{
        new check = randomEx(1, 2);
        switch(check){
            case 1:{
                ClearAnimations(playerid);
                stop roboilsTime[playerid];
                StopProgress(playerid);
                RemovePlayerAttachedObject(playerid, 9);

                new randomOil = random(15)+1;
                
                SendGetMsg(playerid, "น้ำมันดิบ +%d ", randomOil);

                new id = Inventory_Add(playerid, "น้ำมันดิบ", randomOil);
                if (id == -1)
                {
                    ErrorMsg(playerid, "ความจุของกระเป๋าไม่เพียงพอ (%d/%d)", Inventory_Items(playerid), playerData[playerid][pMaxItem]);
                }

                TogglePlayerControllable(playerid, 1);
                statusRobOil{playerid} = false;
                countTime[playerid] = 0;
                delayOilTime[playerid] = 300;
            }
            case 2:{
                ClearAnimations(playerid);
                stop roboilsTime[playerid];
                StopProgress(playerid);
                RemovePlayerAttachedObject(playerid, 9);
                TogglePlayerControllable(playerid, 1);
                statusRobOil{playerid} = false;
                countTime[playerid] = 0;
                delayOilTime[playerid] = 300;
				GivePlayerWanted(playerid, 2);
                SendClientMessage(playerid, COLOR_LIGHTRED, "คุณขโมยน้ำมันดิบไม่สำเร็จ..");

                SendFactionMessageEx(FACTION_POLICE, COLOR_RADIO, "HQ: มีคนกำลังขโมยน้ำมันดิบผิดกฏหมาย, แจ้งเจ้าหน้าที่โปรดตรวจสอบพื้นที่");
            }

        }
    }
    return 1;
}

ptask delayOil[1000](playerid){
    if(delayOilTime[playerid] > 0  && IsPlayerConnected(playerid)){
        delayOilTime[playerid] --;
    }
    return 1;
}

hook OnPlayerUseItem(playerid, const name[])
{
	if (!strcmp(name, "น้ำมันดิบ", true)) {
	    SendClientMessageEx(playerid, X11_WHITE, "วิธีใช้: {00FF00}%s {FFFFFF}สามารถนำไปขาย ได้เงินแดง", name);
	}
}
