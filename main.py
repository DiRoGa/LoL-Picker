import random
from random import randint

import numpy as np
import pyautogui
from python_imagesearch.imagesearch import imagesearch_loop, imagesearch, imagesearch_from_folder
import time
from riotwatcher import LolWatcher, ApiError

pyautogui.FAILSAFE = False
TIMELAPSE = 1

inGame = False

api_key = 'RGAPI-2c00a699-339c-4bae-8ec8-1cb149819b53'
watcher = LolWatcher(api_key)

acceptButtonImg = './pics/accept.jpg'
acceptedButtonImg = './pics/accepted.jpg'
championSelectionImg = './pics/champSelect.png'
playButtonImg = './pics/play-button.png'

roles = {
    "top": {
        "role": "./pics/roles/lanePlayed/TOP.png",
        "champion": "./pics/champs/top",
        "spell1": ['./pics/spells/teleport.png', './pics/spells/ignite.png'],
        "spell2": ['./pics/spells/flash.png', './pics/spells/ghost.png'],
    },

    "jgl": {
        "role": './pics/roles/lanePlayed/JGL.png',
        "champion": "./pics/champs/jgl",
        "spell1": './pics/spells/smite.png',
        "spell2": ['./pics/spells/flash.png', './pics/spells/ghost.png']
    },

    "mid": {
        "role": './pics/roles/lanePlayed/MID.png',
        "champion": "./pics/champs/mid",
        "spell1": ['./pics/spells/teleport.png', './pics/spells/ignite.png', './pics/spells/exhaust.png',
                   './pics/spells/barrier.png', './pics/spells/ghost.png', './pics/spells/cleanse.png'],
        "spell2": './pics/spells/flash.png'
    },

    "adc": {
        "role": './pics/roles/lanePlayed/ADC.png',
        "champion": "./pics/champs/adc",
        "spell1": ['./pics/spells/teleport.png', './pics/spells/ignite.png', './pics/spells/exhaust.png',
                   './pics/spells/cleanse.png'],
        "spell2": './pics/spells/flash.png'
    },

    "sup": {
        "role": './pics/roles/lanePlayed/SUP.png',
        "champion": "./pics/champs/sup",
        "spell1": ['./pics/spells/exhaust.png', './pics/spells/ignite.png', './pics/spells/barrier.png'],
        "spell2": './pics/spells/flash.png'
    }
}


def checkAccount():
    print('Introduce your name, summoner: ')
    user = str(input())
    print('Introduce your region, summoner: ')
    region = str(input())

    try:
        account = watcher.summoner.by_name(region, user)
    except ApiError as err:
        if err.response.status_code == 429:
            print('We should retry in {} seconds.'.format(err.response.headers['Retry-After']))
            print('this retry-after is handled by default by the RiotWatcher library')
            print('future requests wait until the retry-after time passes')
            return False
        elif err.response.status_code == 404:
            print('Summoner with nickname' + user + 'not found, or wrong region introduced')
            return False
        else:
            print('Something went terribly wrong')
            raise Exception("Huh... this shouldn't be happening...")
            return False
    return True


def checkGameAvailableLoop():
    while True:
        pos = imagesearch(acceptButtonImg, 0.8)
        if not pos[0] == -1:
            pyautogui.click(pos[0] + 75, pos[1] + 15)
            print("Game accepted!")
            break

        time.sleep(TIMELAPSE)


def checkGameCancelled():
    accepted = imagesearch(acceptedButtonImg)
    play = imagesearch(playButtonImg)

    if accepted[0] == -1 and not play[0] == -1:
        return True
    else:
        return False


def checkChampionSelection():
    champSel = imagesearch(championSelectionImg)
    if champSel[0] == -1:
        return True
    else:
        return False


def checkLane():
    i = 1
    foundLane = False                                                   # Hay que usar esta función para comprobar que linea le ha sido asignada al usuario
    roles = imagesearch_from_folder('./pics/roles/lanePlayed/', 0.8)    # En teoría hay que sacar iconos (los que resaltan la linea) para identificarlo

    data = list(roles.keys())
    array = np.array(data)
    print(array)

    # for i in range(len(array)):
    while not foundLane:
        print(array[i])
        lane = imagesearch(str(array[i]), 0.8)
        print(lane)

        if lane != -1:
            print
            print('Found lane: ', array[i])
            print(str(foundLane))
            return array[i]
            break
        else:
            i = i + 1


def championSelector(rol = "./pics/roles/lanePlayed/MID.png"):
    pos = imagesearch_loop('./pics/spells/reference.png', 0.8)
    spell1 = pyautogui.moveTo(pos[0] + 300, pos[1] + 25)
    spell2 = pyautogui.moveTo(pos[0] + 350, pos[1] + 25)
    champs = './pics/champs/'

    print(rol)

    if (rol == "./pics/roles/lanePlayed/TOP.PNG"):
        print("You are playing: TOP")
        randint(0, 10)

    elif (rol == "./pics/roles/lanePlayed/JG.PNG"):
        print("You are playing: JGL")
        randint(0, 10)

    elif (rol == "./pics/roles/lanePlayed/MID.PNG"):
        print("You are playing: MID")
        imagesearch(str(roles["mid"]["champion"]) + '/annie.png')
        pyautogui.leftClick()

    elif (rol == "./pics/roles/lanePlayed/ADC.PNG"):
        print("You are playing: ADC")
        randint(0, 10)
        imagesearch(str(roles["adc"]["champion"]) + '/draven.png')
        print("You've chosen: Draven")

    elif (rol == "./pics/roles/lanePlayed/SUP.PNG"):
        print("You are playing: SUPPORT")
        rooster = imagesearch_from_folder(champs + str(roles["sup"]["champion"]))
        champ = random.choice(list(rooster.keys()))
        print("You've chosen: " + str(champ))
        randint(0, 10)

    else:
        print('Unidentified lane :(')


def main():
    run = True

    while (run & checkAccount()) is True:
        checkGameAvailableLoop()
        time.sleep(TIMELAPSE)

        while inGame is False:
            cancelled = checkGameCancelled()

            if cancelled is True:
                print("Game has been cancelled, waiting...")
                break

            else:
                csResult = checkChampionSelection()

                if csResult is True:
                    print("Champion selection! Let's see...")
                    role = championSelector(checkLane())
                    run = False
                    time.sleep(TIMELAPSE)
                    break
                else:
                    break
        break


if __name__ == '__main__':
    print("Running...")
    main()
