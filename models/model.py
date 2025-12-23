import os
from dataclasses import dataclass

from dotenv import  load_dotenv
import requests
import json
from rich.console import Console

class Api_Requests:
    def __init__(self):
        self.api_key = self.__load_api_key()


    def __load_api_key(self):
        load_dotenv()
        return os.getenv("API_KEY")


    def __response_manager(self, url):
        console = Console()
        response = requests.get(url)

        if response.status_code != 200:
            console.print("\nError code: " + str(response.status_code) + "\nReason: " + response.reason + "\n")
            return None

        return response.json()


    def account_data(self, region, name, extension):
        url = ("https://" + region.lower() + ".api.riotgames.com/riot/account/v1/accounts/by-riot-id/" + name.lower() + "/"
               + extension.lower() +"?api_key=" + self.api_key)

        response = self.__response_manager(url)

        url_region = ("https://" + region.lower() + ".api.riotgames.com/riot/account/v1/region/by-game/lol/by-puuid/" +
                  response["puuid"] + "?api_key=" + self.api_key)

        region_response = self.__response_manager(url_region)["region"]

        url_additional_data = ("https://" + region.lower() + ".api.riotgames.com//lol/summoner/v4/summoners/by-puuid/" +
                  response["puuid"] + "?api_key=" + self.api_key)

        additional_data_response = self.__response_manager(url_additional_data)

        user = User(region_response, name, extension, additional_data_response["profileIconId"], additional_data_response["summonerLevel"])
        user.set_puuid(response["puuid"])

        return response, user


    def __map_champion_data(self):
        url = "https://ddragon.leagueoflegends.com/cdn/13.24.1/data/en_US/champion.json"

        response = self.__response_manager(url)["data"]

        # Create a new dictionary with the "champion key" (numerical value)
        sorted_champions = dict()
        for key, value in response.items():
            sorted_champions[int(value["key"])] = {
                "version" : value["version"],
                "name" : value["id"],
                "title" : value["title"],
                "description" : value["blurb"],
                "info" : value["info"],
                "image" : value["image"],
                "tags" : value["tags"],
                "partype" : value["partype"],
                "stats" : value["stats"]
            }

        return sorted_champions


    def user_champion_data(self, user):
        url = ("https://" + user.region + ".api.riotgames.com/lol/champion-mastery/v4/champion-masteries/by-puuid/" +
                user.puuid + "?api_key=" + self.api_key)

        response = self.__response_manager(url)
        mapped_champions = self.__map_champion_data()

        # Top 10 mastery champion info
        for index in range(10):
            if response[index]["championId"] in mapped_champions.keys():
                champion = mapped_champions.get(int(response[index]["championId"]))
                if champion:
                    user.set_champion_pool(int(response[index]["championId"]), champion, response[index]["championPoints"])


    def user_ranked_data(self, user):
        url = ("https://" + user.region + ".api.riotgames.com/lol/league/v4/entries/by-puuid/" + user.puuid + "?api_key=" + self.api_key)

        response = self.__response_manager(url)

        flexq_data = RankedTier.from_api(response[0]["inactive"], response[0])
        soloq_data = RankedTier.from_api(response[1]["inactive"], response[1])

        user.set_ranked_tiers(flexq_data, soloq_data)

class User:
    def __init__(self, *args):
        self.region = args[0]
        self.name = args[1]
        self.extension = args[2]
        self.puuid = ""
        self.level = args[4]
        self.icon = args[3]
        self.champion_pool = list()
        self.ranked_tiers = tuple()


    def set_puuid(self, puuid):
        self.puuid = puuid


    def set_champion_pool(self, id, champion, mastery_points):
        self.champion_pool.append(Champion(champion["version"], id, champion["name"], champion["title"], champion["description"],
                                  champion["info"],champion["image"],champion["tags"],champion["partype"], champion["stats"], mastery_points))


    def set_ranked_tiers(self, soloq_data, flexq_data):
        self.ranked_tiers = (soloq_data, flexq_data)


@dataclass
class Champion:
        version: str
        id: str
        name: str
        title: str
        description: str
        info: str
        image: str
        tags: str
        partype: str
        stats: str
        mastery_points: str


@dataclass
class RankedTier:
    queue_type: str
    tier: str
    rank: str
    points: int
    wins: int
    losses: int

    @classmethod
    def from_api(cls, is_inactive, data: dict):
        if is_inactive:
            return None

        return cls(
            queue_type=data["queueType"],
            tier=data["tier"],
            rank=data["rank"],
            points=data["leaguePoints"],
            wins=data["wins"],
            losses=data["losses"]
        )
