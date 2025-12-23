from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.align import Align
from rich.text import Text
from rich.layout import Layout

from models.model import Api_Requests

api = Api_Requests()
console = Console()

# =========================
# HEADER
# =========================
def print_header():
    console.clear()
    console.print(
        Align.center(
            Panel(
                "[bold magenta]LoL Picker[/]\n[italic]Let the script do the rest[/]",
                border_style="magenta",
                padding=(1, 4)
            )
        )
    )


def render_header():
    return Panel(
        "[bold magenta]LoL Picker[/]\n[italic]Let the script do the rest[/]",
        border_style="magenta",
        padding=(1, 2)
    )


# =========================
# ACCOUNT SETUP
# =========================
def account_setup_menu():
    regions = ["europe", "north america", "asia"]

    print_header()

    table = Table(show_header=True, header_style="bold cyan")
    table.add_column("Available regions", justify="center")

    for region in regions:
        table.add_row(region)

    console.print(table)

    console.print("\nSelect a region:", style="italic", end=" ")
    summoner_region = input().lower()

    if summoner_region not in regions:
        raise ValueError("The region you chose isn't available or doesn't exist")

    console.print("Type in your summoner name:", style="italic", end=" ")
    summoner_name = input()

    console.print("Type in your summoner extension (#):", style="italic", end=" ")
    summoner_extension = input()

    console.print("\nConnecting to Riot API...", style="italic")

    response, user = api.account_data(
        summoner_region,
        summoner_name,
        summoner_extension
    )

    if not response or "puuid" not in response:
        console.print("Error retrieving account data", style="bold red")
        return None

    console.print(
        f"\n✔ Welcome [bold green]{summoner_name}#{summoner_extension}[/]",
    )

    return user


# =========================
# MAIN MENU
# =========================
def render_main_menu():
    table = Table(show_header=True, header_style="bold cyan", expand=True)
    table.add_column("Option", justify="center", style="bold")
    table.add_column("Description")

    table.add_row("1", "🏆 Most played champions")
    table.add_row("2", "📊 Profile statistics")
    table.add_row("3", "🕹 Match history")
    table.add_row("0", "❌ Exit")

    return Panel(
        table,
        title="Menu",
        border_style="magenta"
    )


def main_menu(account):
    layout = Layout()

    layout.split_column(
        Layout(name="header", size=5),
        Layout(name="body")
    )

    layout["body"].split_row(
        Layout(name="menu", size=38),
        Layout(name="content")
    )

    content_panel = Panel(
        "[italic dim]Select an option from the menu[/]",
        border_style="dim"
    )

    while True:
        layout["header"].update(render_header())
        layout["menu"].update(render_main_menu())
        layout["content"].update(content_panel)

        console.clear()
        console.print(layout)

        choice = input("\nSelect an option: ")

        match choice:
            case "1":
                content_panel = render_most_played_champions(account)
            case "2":
                content_panel = render_ranked_stats(account)
            case "3":
                content_panel = Panel(
                    "🕹 Match history coming soon...",
                    border_style="yellow"
                )
            case "0":
                break
            case _:
                content_panel = Panel(
                    "[bold red]Invalid option[/]",
                    border_style="red"
                )


# =========================
# MENU OPTIONS
# =========================
def render_most_played_champions(account):
    api.user_champion_data(account)

    if not account.champion_pool:
        return Panel(
            "[italic red]No champion data available[/]",
            title="Error",
            border_style="red"
        )

    champions = sorted(
        account.champion_pool,
        key=lambda c: c.mastery_points,
        reverse=True
    )

    table = Table(
        show_header=True,
        header_style="bold cyan",
        expand=True,
        show_lines=False
    )

    table.add_column(
        "Champion",
        style="bold magenta",
        no_wrap=True
    )
    table.add_column(
        "Description",
        overflow="fold",
        ratio=3
    )
    table.add_column(
        "Mastery Points",
        justify="right",
        style="bold green",
        no_wrap=True
    )

    for champ in champions:
        champion_name = Text.assemble(
            (champ.name, "bold"),
            (" — ", "dim"),
            (champ.title, "italic")
        )

        table.add_row(
            champion_name,
            f"{champ.description}\n",
            f"{champ.mastery_points:,}"
        )

    return Panel(
        table,
        title="🏆 Most Played Champions",
        border_style="magenta",
        padding=(1, 1)
    )


def render_ranked_stats(user):
    api.user_ranked_data(user)

    table = Table(show_header=True, header_style="bold cyan", expand=True)
    table.add_column("Queue")
    table.add_column("Tier")
    table.add_column("LP", justify="right")
    table.add_column("Winrate", justify="right")

    for ranked in user.ranked_tiers:
        if ranked is None:
            continue

        total = ranked.wins + ranked.losses
        winrate = f"{ranked.wins / total * 100:.1f}%"

        table.add_row(
            ranked.queue_type,
            f"{ranked.tier} {ranked.rank}",
            str(ranked.points),
            winrate
        )

    return Panel(
        table,
        title="📊 Ranked Stats",
        border_style="cyan"
    )


def show_match_history(account):
    console.clear()
    console.print("🕹 [bold magenta]Match history[/]\n")

    # Placeholder para API real
    # matches = api_requests.get_match_history(account["puuid"])

    console.print("Feature coming soon...", style="italic")
    input("\nPress ENTER to return to menu...")


# =========================
# ENTRY POINT
# =========================
def main():
    account = account_setup_menu()

    if account:
        main_menu(account)


if __name__ == "__main__":
    main()
