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
        CreateDynamic3DTextLabel("[���¹���ѹ]\n����� '/stealoil' ���͢���", COLOR_YELLOW, posRobOil[i][0], posRobOil[i][1], posRobOil[i][2], 3.0); //
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

            InfoMsg(playerid, "�س��¡��ԡ��â��¹���ѹ�Ժ����.");
        }
    }
    return 1;
}

alias:stealoil("���¹���ѹ")
CMD:stealoil(playerid){

    for(new i = 0; i < sizeof(posRobOil); i ++) 
    {
        if (IsPlayerInRangeOfPoint(playerid, 3.0, posRobOil[i][0], posRobOil[i][1], posRobOil[i][2]))
        {
            if(GetFactionOnline(FACTION_POLICE) < 1) return ErrorMsg(playerid, "��й����������˹�ҷ����Ǩ�͹�Ź� �������ö��������ҹ��..");

            if(GetPlayerWantedLevelEx(playerid) > 0) return ErrorMsg(playerid, "�س�е�ͧ���Դ���!!");

            if(delayOilTime[playerid] > 0)
                return ErrorMsg(playerid, " �ô���ա�ѡ����֧��������������ա���� (%d �Թҷ�)", delayOilTime[playerid]);

            if(statusRobOil{playerid} == true)
                return ErrorMsg(playerid, " �س���ѧ��������..");

            if(statusRobOil{playerid} == false){
                InfoMsg(playerid, "���ѧ������鹢��¹���ѹ...");
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
                
                SendGetMsg(playerid, "����ѹ�Ժ +%d ", randomOil);

                new id = Inventory_Add(playerid, "����ѹ�Ժ", randomOil);
                if (id == -1)
                {
                    ErrorMsg(playerid, "�����آͧ�����������§�� (%d/%d)", Inventory_Items(playerid), playerData[playerid][pMaxItem]);
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
                SendClientMessage(playerid, COLOR_LIGHTRED, "�س���¹���ѹ�Ժ��������..");

                SendFactionMessageEx(FACTION_POLICE, COLOR_RADIO, "HQ: �դ����ѧ���¹���ѹ�Ժ�Դ������, �����˹�ҷ���ô��Ǩ�ͺ��鹷��");
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
	if (!strcmp(name, "����ѹ�Ժ", true)) {
	    SendClientMessageEx(playerid, X11_WHITE, "�Ը���: {00FF00}%s {FFFFFF}����ö��仢�� ���Թᴧ", name);
	}
}
