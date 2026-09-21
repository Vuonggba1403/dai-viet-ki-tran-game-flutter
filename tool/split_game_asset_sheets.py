from __future__ import annotations

import math
from collections import defaultdict
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps


DOWNLOADS = Path(r"D:\UserData\Applications\Downloads")
OUTPUT = Path("assets/images/game")

SHEETS = {
    "tiles": DOWNLOADS / "ChatGPT Image 23_21_33 21 thg 9, 2026 (1).png",
    "specials": DOWNLOADS / "ChatGPT Image 23_21_33 21 thg 9, 2026 (2).png",
    "combat_vfx": DOWNLOADS / "ChatGPT Image 23_21_35 21 thg 9, 2026 (3).png",
    "battle_ui": DOWNLOADS / "ChatGPT Image 23_21_36 21 thg 9, 2026 (5).png",
    "items": DOWNLOADS / "ChatGPT Image 23_21_37 21 thg 9, 2026 (6).png",
    "backgrounds": DOWNLOADS / "ChatGPT Image 23_21_37 21 thg 9, 2026 (7).png",
    "enemies": DOWNLOADS / "ChatGPT Image 23_21_38 21 thg 9, 2026 (8).png",
    "status_vfx": DOWNLOADS / "ChatGPT Image 23_21_36 21 thg 9, 2026 (4).png",
}


def load(name: str) -> Image.Image:
    path = SHEETS[name]
    if not path.is_file():
        raise FileNotFoundError(path)
    return Image.open(path).convert("RGBA")


def trim(image: Image.Image, padding: int = 8) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[rgba[:, :, 3] <= 8] = 0
    cleaned = Image.fromarray(rgba, "RGBA")
    bbox = cleaned.getbbox(alpha_only=True)
    if bbox is None:
        raise ValueError("Asset region is empty")
    cropped = cleaned.crop(bbox)
    canvas = Image.new(
        "RGBA",
        (cropped.width + padding * 2, cropped.height + padding * 2),
        (0, 0, 0, 0),
    )
    canvas.alpha_composite(cropped, (padding, padding))
    return canvas


def nearest_clear_boundary(
    alpha: np.ndarray,
    target: int,
    axis: int,
    radius: int = 32,
) -> int:
    size = alpha.shape[axis]
    start = max(1, target - radius)
    end = min(size - 1, target + radius + 1)
    if axis == 0:
        coverage = np.count_nonzero(alpha[start:end] > 8, axis=1)
    else:
        coverage = np.count_nonzero(alpha[:, start:end] > 8, axis=0)
    distance = np.abs(np.arange(start, end) - target)
    score = coverage.astype(np.float64) + distance * 0.05
    return start + int(np.argmin(score))


def split_rows(
    image: Image.Image,
    row_targets: list[int],
    column_targets_by_row: list[list[int]],
    *,
    adjust_boundaries: bool = True,
) -> list[Image.Image]:
    alpha = np.asarray(image)[:, :, 3]
    row_boundaries = (
        [
            nearest_clear_boundary(alpha, target, axis=0, radius=36)
            for target in row_targets
        ]
        if adjust_boundaries
        else row_targets
    )
    y_bounds = [0, *row_boundaries, image.height]
    assets: list[Image.Image] = []

    for row_index, column_targets in enumerate(column_targets_by_row):
        top, bottom = y_bounds[row_index : row_index + 2]
        row_alpha = alpha[top:bottom]
        column_boundaries = (
            [
                nearest_clear_boundary(row_alpha, target, axis=1, radius=40)
                for target in column_targets
            ]
            if adjust_boundaries
            else column_targets
        )
        x_bounds = [0, *column_boundaries, image.width]
        for left, right in zip(x_bounds, x_bounds[1:]):
            assets.append(trim(image.crop((left, top, right, bottom))))
    return assets


def regular_grid(image: Image.Image, columns: int, rows: int) -> list[Image.Image]:
    row_targets = [round(image.height * index / rows) for index in range(1, rows)]
    column_targets = [round(image.width * index / columns) for index in range(1, columns)]
    return split_rows(image, row_targets, [column_targets] * rows)


def crop_assets(
    image: Image.Image,
    regions: list[tuple[str, tuple[int, int, int, int]]],
) -> dict[str, Image.Image]:
    return {name: trim(image.crop(box)) for name, box in regions}


def connected_components(image: Image.Image) -> list[Image.Image]:
    rgba = np.asarray(image.convert("RGBA"))
    mask = rgba[:, :, 3] > 8
    parent: list[int] = []
    runs: list[tuple[int, int, int, int]] = []
    previous: list[tuple[int, int, int]] = []

    def find(label: int) -> int:
        while parent[label] != label:
            parent[label] = parent[parent[label]]
            label = parent[label]
        return label

    def union(first: int, second: int) -> int:
        first = find(first)
        second = find(second)
        if first == second:
            return first
        if first > second:
            first, second = second, first
        parent[second] = first
        return first

    for y, row in enumerate(mask):
        padded = np.pad(row.astype(np.int8), (1, 1))
        differences = np.diff(padded)
        starts = np.flatnonzero(differences == 1)
        ends = np.flatnonzero(differences == -1) - 1
        current: list[tuple[int, int, int]] = []
        previous_index = 0
        for start, end in zip(starts, ends):
            label = len(parent)
            parent.append(label)
            while (
                previous_index < len(previous)
                and previous[previous_index][1] < start - 1
            ):
                previous_index += 1
            overlap_index = previous_index
            while (
                overlap_index < len(previous)
                and previous[overlap_index][0] <= end + 1
            ):
                label = union(label, previous[overlap_index][2])
                overlap_index += 1
            current.append((int(start), int(end), find(label)))
            runs.append((y, int(start), int(end), label))
        previous = current

    grouped_runs: defaultdict[int, list[tuple[int, int, int]]] = defaultdict(list)
    for y, start, end, label in runs:
        grouped_runs[find(label)].append((y, start, end))

    components: list[Image.Image] = []
    for component_runs in grouped_runs.values():
        area = sum(end - start + 1 for _, start, end in component_runs)
        if area < 100:
            continue
        isolated = np.zeros_like(rgba)
        for y, start, end in component_runs:
            isolated[y, start : end + 1] = rgba[y, start : end + 1]
        components.append(Image.fromarray(isolated, "RGBA"))
    return components


def pick_component(
    components: list[Image.Image],
    anchor: tuple[int, int],
) -> Image.Image:
    candidates: list[tuple[float, Image.Image]] = []
    for component in components:
        bbox = component.getbbox(alpha_only=True)
        if bbox is None:
            continue
        center_x = (bbox[0] + bbox[2]) / 2
        center_y = (bbox[1] + bbox[3]) / 2
        distance = (center_x - anchor[0]) ** 2 + (center_y - anchor[1]) ** 2
        candidates.append((distance, component))
    return min(candidates, key=lambda candidate: candidate[0])[1]


def normalize(
    assets: dict[str, Image.Image],
    names: list[str],
    *,
    bottom_aligned: bool = False,
) -> None:
    width = math.ceil(max(assets[name].width for name in names) / 2) * 2
    height = math.ceil(max(assets[name].height for name in names) / 2) * 2
    for name in names:
        source = assets[name]
        canvas = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        x = (width - source.width) // 2
        y = height - source.height if bottom_aligned else (height - source.height) // 2
        canvas.alpha_composite(source, (x, y))
        assets[name] = canvas


def save_assets(assets: dict[str, Image.Image]) -> None:
    directories = {str(Path(name).parent) for name in assets}
    for directory in directories:
        output_dir = OUTPUT / directory
        output_dir.mkdir(parents=True, exist_ok=True)
        for existing in output_dir.glob("*.png"):
            existing.unlink()

    for relative_path, image in assets.items():
        destination = OUTPUT / f"{relative_path}.png"
        destination.parent.mkdir(parents=True, exist_ok=True)
        image.save(destination, optimize=True)


def extract_tiles(assets: dict[str, Image.Image]) -> None:
    names = [
        "tiles/base/sword",
        "tiles/base/sword_ready",
        "tiles/base/fire",
        "tiles/base/fire_ready",
        "tiles/base/water",
        "tiles/base/water_ready",
        "tiles/base/lightning",
        "tiles/base/lightning_ready",
        "tiles/base/heart",
        "tiles/base/heart_ready",
        "tiles/base/shield",
        "tiles/base/shield_ready",
    ]
    assets.update(dict(zip(names, regular_grid(load("tiles"), 4, 3), strict=True)))
    normalize(assets, names)


def extract_specials(assets: dict[str, Image.Image]) -> None:
    names = [
        "tiles/special/bomb",
        "tiles/special/line_horizontal",
        "tiles/special/line_vertical",
        "tiles/special/power_gem",
        "tiles/special/power_sword",
        "tiles/special/power_shadow",
        "tiles/overlays/selected",
        "tiles/overlays/locked",
        "tiles/overlays/frozen",
        "tiles/overlays/poisoned",
        "tiles/overlays/stunned",
        "tiles/overlays/cracked",
    ]
    assets.update(dict(zip(names, regular_grid(load("specials"), 6, 2), strict=True)))
    normalize(assets, names[:6])
    normalize(assets, names[6:])


def extract_combat_vfx(assets: dict[str, Image.Image]) -> None:
    names = [
        "vfx/combat/water_slash_wide",
        "vfx/combat/water_slash_arc",
        "vfx/projectiles/water_blade",
        "vfx/combat/earth_impact_01",
        "vfx/combat/earth_impact_02",
        "vfx/combat/earth_impact_ring",
        "vfx/combat/dust_impact",
        "vfx/projectiles/arrow",
        "vfx/combat/impact_yellow_01",
        "vfx/combat/impact_yellow_02",
        "vfx/combat/impact_red",
        "vfx/combat/water_slash_01",
        "vfx/combat/water_slash_02",
        "vfx/combat/water_slash_03",
        "vfx/projectiles/water_wave",
        "vfx/combat/impact_gold_ring",
    ]
    images = split_rows(
        load("combat_vfx"),
        [300, 610, 840],
        [
            [510, 915],
            [415, 715, 1100],
            [510, 780, 1090],
            [220, 410, 640, 1015],
        ],
        adjust_boundaries=False,
    )
    assets.update(dict(zip(names, images, strict=True)))


def extract_battle_ui(assets: dict[str, Image.Image]) -> None:
    image = load("battle_ui")
    components = connected_components(image)
    component_anchors = {
        "ui/battle/skill_button_physical": (1000, 175),
        "ui/battle/skill_button_water": (1300, 190),
        "ui/battle/pause_button": (920, 430),
        "ui/battle/speed_normal_button": (1120, 430),
        "ui/battle/speed_fast_button": (1330, 430),
        "ui/battle/enemy_target_frame": (160, 650),
        "ui/battle/turn_counter": (450, 640),
        "ui/battle/combo_badge": (780, 640),
        "ui/battle/info_panel": (1210, 710),
        "ui/battle/victory_banner": (270, 910),
        "ui/battle/defeat_banner": (770, 900),
        "ui/battle/confirm_button": (1070, 990),
        "ui/battle/cancel_button": (1245, 990),
        "ui/battle/close_button": (1390, 985),
    }
    extracted = {
        name: trim(pick_component(components, anchor))
        for name, anchor in component_anchors.items()
    }

    health_assets = crop_assets(
        image,
        [
            ("ui/battle/health_bar_empty", (0, 0, 820, 148)),
            ("ui/battle/health_bar_full", (0, 148, 820, 290)),
        ],
    )
    mana_component = pick_component(components, (410, 410))
    mana_assets = crop_assets(
        mana_component,
        [
            ("ui/battle/mana_bar_empty", (0, 285, 820, 414)),
            ("ui/battle/mana_bar_full", (0, 414, 820, 550)),
        ],
    )
    extracted.update(health_assets)
    extracted.update(mana_assets)
    assets.update(extracted)
    normalize(
        assets,
        [
            "ui/battle/health_bar_empty",
            "ui/battle/health_bar_full",
            "ui/battle/mana_bar_empty",
            "ui/battle/mana_bar_full",
        ],
    )


def extract_items(assets: dict[str, Image.Image]) -> None:
    names = [
        "items/currency/gold",
        "items/currency/gem",
        "items/consumables/energy_potion",
        "items/consumables/summon_scroll",
        "items/materials/hero_fragment",
        "items/materials/ascension_crystal",
        "rewards/chest",
        "items/consumables/stage_key",
        "items/consumables/health_potion",
        "items/consumables/mana_potion",
        "items/equipment/weapon_sword",
        "items/equipment/armor",
        "items/equipment/accessory_ring",
        "items/equipment/relic_orb",
        "items/materials/fire",
        "items/materials/water",
        "items/materials/lightning",
        "items/materials/heart",
        "items/materials/shield",
        "rewards/star",
    ]
    assets.update(dict(zip(names, regular_grid(load("items"), 5, 4), strict=True)))
    normalize(assets, names)


def extract_backgrounds(assets: dict[str, Image.Image]) -> None:
    image = load("backgrounds")
    regions = {
        "backgrounds/battle/grassland_path": (0, 0, 720, 539),
        "backgrounds/battle/castle_courtyard": (728, 0, 1448, 539),
        "backgrounds/battle/lakeside": (0, 547, 720, 1086),
        "backgrounds/battle/enchanted_forest": (728, 547, 1448, 1086),
    }
    for name, box in regions.items():
        assets[name] = image.crop(box)


def extract_enemies(assets: dict[str, Image.Image]) -> None:
    source_frames = regular_grid(load("enemies"), 3, 4)
    enemy_specs = (
        ("bandit", "attack"),
        ("goblin_bomber", "attack"),
        ("skeleton_archer", "attack"),
        ("necromancer", "skill"),
    )
    for enemy_index, (enemy, action) in enumerate(enemy_specs):
        row = source_frames[enemy_index * 3 : enemy_index * 3 + 3]
        names = [
            f"enemies/{enemy}/idle_left",
            f"enemies/{enemy}/idle_right",
            f"enemies/{enemy}/{action}_right_01",
        ]
        assets.update(dict(zip(names, row, strict=True)))
        normalize(assets, names, bottom_aligned=True)
        right_name = names[-1]
        left_name = right_name.replace("_right_", "_left_")
        assets[left_name] = ImageOps.mirror(assets[right_name])


def extract_status_vfx(assets: dict[str, Image.Image]) -> None:
    names = [
        "vfx/elemental/fire_slash",
        "vfx/elemental/fire_explosion",
        "vfx/elemental/water_splash",
        "vfx/elemental/water_wave",
        "vfx/elemental/lightning_strike",
        "vfx/elemental/earth_orb",
        "vfx/status/heal",
        "vfx/status/regen",
        "vfx/status/shield",
        "vfx/status/attack_up",
        "vfx/status/defense_down",
        "vfx/status/poison",
        "vfx/status/burn",
        "vfx/status/stun",
        "vfx/status/holy_blessing",
    ]
    images = split_rows(
        load("status_vfx"),
        [405, 755],
        [
            [360, 735, 1072],
            [245, 495, 730, 945, 1200],
            [280, 590, 840, 1130],
        ],
        adjust_boundaries=False,
    )
    assets.update(dict(zip(names, images, strict=True)))


def main() -> None:
    assets: dict[str, Image.Image] = {}
    extract_tiles(assets)
    extract_specials(assets)
    extract_combat_vfx(assets)
    extract_battle_ui(assets)
    extract_items(assets)
    extract_backgrounds(assets)
    extract_enemies(assets)
    extract_status_vfx(assets)
    save_assets(assets)

    counts: defaultdict[str, int] = defaultdict(int)
    for name in assets:
        counts[name.split("/", maxsplit=1)[0]] += 1
    print(f"Saved {len(assets)} assets: {dict(sorted(counts.items()))}")


if __name__ == "__main__":
    main()
