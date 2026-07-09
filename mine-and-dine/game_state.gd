extends Node
## Autoload singleton: stan prototypu + części maszyn + staty pochodne + ekonomia.
## Kaskada: Koparka->Wywrotka->Płuczka->Pompa->Stół.
## Każda maszyna ma 5 części — ulepszasz części, one podnoszą "moc" maszyny.

signal cash_changed(value)
signal raw_gold_changed(value)
signal price_changed(value)
signal upgraded(machine)
signal goal_changed(progress, target)

var cash: float = 150.0        # gotówka ($)
var raw_gold: float = 0.0      # surowe złoto (gramy)

# --- działka + cel sesji (baner) ---
var plot_name := "Kalifornia"
var plot_number := 6767
var plot_goal := 50.0          # cel w gramach (łączne wydobycie)
var plot_progress := 0.0       # łączne wydobyte złoto na tej działce

var order := ["excavator", "truck", "wash", "pump", "table"]

var machine_names := {
	"excavator": "Koparka", "truck": "Wywrotka", "wash": "Płuczka",
	"pump": "Pompa", "table": "Stół",
}

var machine_role := {
	"excavator": "Wydobywa urobek — rozmiar hałdy i szansa na złoże",
	"truck": "Wozi urobek — tempo kolejnego SYP",
	"wash": "Przesiewa — okno na błysk i auto-odzysk",
	"pump": "Podaje wodę — szybkość czyszczenia",
	"table": "Oczyszcza koncentrat — złoto za grudkę",
}

var base_cost := {
	"excavator": 40.0, "truck": 32.0, "wash": 46.0, "pump": 34.0, "table": 44.0,
}

# 5 części na maszynę: key / nazwa / statystyka którą reprezentuje
var part_defs := {
	"excavator": [
		{"key": "lyzka", "name": "Łyżka", "stat": "Pojemność łyżki"},
		{"key": "silnik", "name": "Silnik", "stat": "Szybkość pracy"},
		{"key": "hydraulika", "name": "Hydraulika", "stat": "Siła kopania"},
		{"key": "gasienice", "name": "Gąsienice", "stat": "Mobilność"},
		{"key": "ramie", "name": "Ramię koparki", "stat": "Zasięg / awaryjność"},
	],
	"truck": [
		{"key": "skrzynia", "name": "Skrzynia ładunkowa", "stat": "Ładowność"},
		{"key": "silnik", "name": "Silnik", "stat": "Prędkość jazdy"},
		{"key": "opony", "name": "Opony", "stat": "Trakcja"},
		{"key": "zawieszenie", "name": "Zawieszenie", "stat": "Wytrzymałość"},
		{"key": "hamulce", "name": "Układ hamulcowy", "stat": "Bezpieczeństwo"},
	],
	"wash": [
		{"key": "hopper", "name": "Hopper / zasobnik", "stat": "Przepustowość"},
		{"key": "beben", "name": "Bęben przesiewający", "stat": "Skuteczność odzysku"},
		{"key": "sita", "name": "Sita", "stat": "Dokładność"},
		{"key": "maty", "name": "Maty do złota", "stat": "Zatrzymanie złota"},
		{"key": "rynny", "name": "Rynny płuczące", "stat": "Stabilność pracy"},
	],
	"pump": [
		{"key": "silnik", "name": "Silnik pompy", "stat": "Wydajność"},
		{"key": "wirnik", "name": "Wirnik", "stat": "Ciśnienie wody"},
		{"key": "filtr", "name": "Filtr wstępny", "stat": "Odporność"},
		{"key": "rury", "name": "Przewody / rury", "stat": "Zasięg tłoczenia"},
		{"key": "zawory", "name": "Zawory ciśnieniowe", "stat": "Kontrola ciśnienia"},
	],
	"table": [
		{"key": "blat", "name": "Blat separacyjny", "stat": "Precyzja separacji"},
		{"key": "wibro", "name": "Silnik wibracyjny", "stat": "Szybkość oczyszczania"},
		{"key": "nachylenie", "name": "Regulacja nachylenia", "stat": "Kalibracja"},
		{"key": "doplyw", "name": "Dopływ wody", "stat": "Płukanie"},
		{"key": "mata", "name": "Mata robocza", "stat": "Zatrzymanie drobin"},
	],
}

var part_levels := {}   # machine -> { key: level }

# części ⚙ zablokowane — brak efektu, czekają na przyszły system
var locked_parts := {
	"truck": ["opony", "zawieszenie", "hamulce"],
	"wash": ["hopper", "rynny"],
	"pump": ["filtr", "rury", "zawory"],
	"table": ["wibro", "doplyw"],
}

func is_locked(m: String, key: String) -> bool:
	return locked_parts.has(m) and key in locked_parts[m]

# efektywny poziom części (0 przy lvl 1)
func _e(m: String, key: String) -> int:
	return part_levels[m][key] - 1

# --- bonusy z części (loot popupy) ---
var bonus_gold_mult: float = 1.0
var bonus_glint_add: float = 0.0
var bonus_reload_mult: float = 1.0

# --- symulowany kurs złota (zmiana co 5s, z zakresu) ---
var price: float = 60.0
var price_min: float = 42.0
var price_max: float = 84.0
var price_history: Array = []   # ostatnie ~40 kursów (wykres)
const PRICE_HISTORY_MAX := 40

func _ready() -> void:
	for m in part_defs.keys():
		var d := {}
		for p in part_defs[m]:
			d[p.key] = 1
		part_levels[m] = d
	for i in range(12):
		price_history.append(price)

# efektywny poziom maszyny = suma poziomów jej 5 części (5x lvl1 -> 1)
# (zostaje tylko do etykiety "moc" na liście maszyn)
func machine_level(m: String) -> int:
	var s := 0
	for k in part_levels[m].keys():
		s += part_levels[m][k]
	return s - 4

# ---------------- staty pochodne (każda część -> własna zmienna) ----------------
# KOPARKA
func pile_scale() -> float:
	return 1.0 + 0.15 * _e("excavator", "lyzka")

func shake_target() -> float:
	return maxf(400.0, 1100.0 - 90.0 * _e("excavator", "silnik"))

func glint_chance() -> float:
	return clampf(0.35 + 0.04 * _e("excavator", "hydraulika") + bonus_glint_add, 0.05, 0.92)

func nugget_count() -> int:
	return 2 + int(floor(_e("excavator", "gasienice") / 2.0))

func gold_grade() -> float:
	return 1.0 + 0.12 * _e("excavator", "ramie")

# WYWROTKA
func bonus_nugget_chance() -> float:
	return clampf(0.06 * _e("truck", "skrzynia"), 0.0, 0.8)

func reload_time() -> float:
	return maxf(0.5, (2.2 - 0.16 * _e("truck", "silnik")) * bonus_reload_mult)

# PŁUCZKA
func auto_recovery() -> float:
	return clampf(0.08 + 0.035 * _e("wash", "beben"), 0.0, 0.6)

func glint_window() -> float:
	return 1.7 + 0.18 * _e("wash", "sita")

func gold_mult_wash() -> float:
	return 1.0 + 0.08 * _e("wash", "maty")

# POMPA
func water_power() -> float:
	return 1.0 + 0.30 * _e("pump", "silnik")

func water_radius() -> float:
	return 90.0 + 12.0 * _e("pump", "wirnik")

# STÓŁ
func pick_recovery() -> float:
	return clampf(0.15 + 0.05 * _e("table", "blat"), 0.0, 0.7)

func gold_retain_mult() -> float:
	return 1.0 + 0.06 * _e("table", "mata")

func gold_per_nugget() -> float:
	return (0.8 + 0.18 * _e("table", "nachylenie")) * bonus_gold_mult * gold_grade() * gold_mult_wash() * gold_retain_mult()  # gramy

# ---------------- części: koszt / upgrade / wartość statu ----------------
func part_cost(m: String, key: String) -> float:
	var lvl: int = part_levels[m][key]
	return round(base_cost[m] * 0.45 * pow(1.42, lvl - 1))

func can_upgrade_part(m: String, key: String) -> bool:
	return cash >= part_cost(m, key)

func upgrade_part(m: String, key: String) -> bool:
	if is_locked(m, key):
		return false
	var c := part_cost(m, key)
	if cash < c:
		return false
	cash -= c
	part_levels[m][key] += 1
	cash_changed.emit(cash)
	upgraded.emit(m)
	return true

# PRAWDZIWY efekt części do wyświetlenia (odczyt realnych zmiennych gameplayu)
func part_effect_text(m: String, key: String) -> String:
	if is_locked(m, key):
		return "🔒 wymaga systemu (wkrótce)"
	match m:
		"excavator":
			match key:
				"lyzka": return "Rozmiar hałdy: %d%%" % round(pile_scale() * 100)
				"silnik": return "Próg strząsania: %d" % int(shake_target())
				"hydraulika": return "Szansa na błysk: %d%%" % round(glint_chance() * 100)
				"gasienice": return "Grudki/hałda: %d" % nugget_count()
				"ramie": return "Jakość złota: x%.2f" % gold_grade()
		"truck":
			match key:
				"skrzynia": return "Szansa +1 grudka: %d%%" % round(bonus_nugget_chance() * 100)
				"silnik": return "Czas SYP: %.2fs" % reload_time()
		"wash":
			match key:
				"beben": return "Auto-odzysk: %d%%" % round(auto_recovery() * 100)
				"sita": return "Okno błysku: %.2fs" % glint_window()
				"maty": return "Mnożnik złota: x%.2f" % gold_mult_wash()
		"pump":
			match key:
				"silnik": return "Moc wody: x%.2f" % water_power()
				"wirnik": return "Promień: %d" % int(water_radius())
		"table":
			match key:
				"blat": return "Odzysk fines: %d%%" % round(pick_recovery() * 100)
				"nachylenie": return "Złoto/grudkę: %.2f g" % gold_per_nugget()
				"mata": return "Zatrzymanie: x%.2f" % gold_retain_mult()
	return "—"

func part_level(m: String, key: String) -> int:
	return part_levels[m][key]

func part_display_name(m: String, key: String) -> String:
	for p in part_defs[m]:
		if p.key == key:
			return p.name
	return key

# ---------------- ekonomia ----------------
func add_cash(v: float) -> void:
	cash += v
	cash_changed.emit(cash)

func add_raw_gold(v: float, to_goal: bool = true) -> void:
	raw_gold += v
	raw_gold_changed.emit(raw_gold)
	if to_goal:  # idle NIE liczy się do celu — tylko aktywne wydobycie
		plot_progress += v
		goal_changed.emit(plot_progress, plot_goal)

func sell_all() -> float:
	var earned := raw_gold * price
	cash += earned
	raw_gold = 0.0
	cash_changed.emit(cash)
	raw_gold_changed.emit(raw_gold)
	return earned

func tick_price() -> void:
	price = clampf(price + randf_range(-7.0, 7.0), price_min, price_max)
	price_history.append(price)
	if price_history.size() > PRICE_HISTORY_MAX:
		price_history.pop_front()
	price_changed.emit(price)

# ---------------- działki / lokacje + pracownicy IDLE ----------------
signal workers_changed

const MAX_WORKERS := 5
const IDLE_G_PER_WORKER_PER_MIN := 0.5   # pracownik: powoli, na minutę

var locations := [
	{"id": "california", "name": "Kalifornia", "unlocked": true, "unlock_cost": 0.0},
	{"id": "alaska", "name": "Alaska", "unlocked": false, "unlock_cost": 2000.0},
]
var workers := {"california": 0, "alaska": 0}

func location_by_id(id: String) -> Dictionary:
	for l in locations:
		if l.id == id:
			return l
	return {}

func is_unlocked(id: String) -> bool:
	return location_by_id(id).get("unlocked", false)

func unlock_cost(id: String) -> float:
	return location_by_id(id).get("unlock_cost", 0.0)

func unlock_location(id: String) -> bool:
	var loc := location_by_id(id)
	if loc.is_empty() or loc.unlocked:
		return false
	var c: float = loc.unlock_cost
	if cash < c:
		return false
	cash -= c
	loc.unlocked = true
	cash_changed.emit(cash)
	workers_changed.emit()
	return true

func worker_count(id: String) -> int:
	return workers.get(id, 0)

func worker_cost(id: String) -> float:
	return round(120.0 * pow(1.5, worker_count(id)))

func can_buy_worker(id: String) -> bool:
	return is_unlocked(id) and worker_count(id) < MAX_WORKERS and cash >= worker_cost(id)

func buy_worker(id: String) -> bool:
	if not can_buy_worker(id):
		return false
	cash -= worker_cost(id)
	workers[id] = worker_count(id) + 1
	cash_changed.emit(cash)
	workers_changed.emit()
	return true

func total_workers() -> int:
	var s := 0
	for k in workers.keys():
		s += workers[k]
	return s

# łączny idle: gramy złota na SEKUNDĘ od wszystkich pracowników (bardzo wolno)
func idle_rate() -> float:
	return total_workers() * IDLE_G_PER_WORKER_PER_MIN / 60.0

# ---------------- loot części ----------------
# rzadkości części — waga losowania, mnożnik siły/ceny, kolor
var rarities := [
	{"id": "common", "name": "Zwykła", "color": Color(0.78, 0.78, 0.80), "weight": 55, "mult": 1.0},
	{"id": "uncommon", "name": "Niezwykła", "color": Color(0.45, 0.88, 0.45), "weight": 28, "mult": 1.6},
	{"id": "rare", "name": "Rzadka", "color": Color(0.40, 0.66, 1.0), "weight": 13, "mult": 2.4},
	{"id": "epic", "name": "Epicka", "color": Color(0.80, 0.45, 0.96), "weight": 4, "mult": 3.6},
]

func _roll_rarity() -> Dictionary:
	var total := 0
	for r in rarities:
		total += r.weight
	var pick := randi() % total
	var acc := 0
	for r in rarities:
		acc += r.weight
		if pick < acc:
			return r
	return rarities[0]

func roll_part() -> Dictionary:
	var m: String = order[randi() % order.size()]
	var kinds := ["gold", "glint", "reload"]
	var kind: String = kinds[randi() % kinds.size()]
	var rar := _roll_rarity()
	var mag := 0.0
	var desc := ""
	match kind:
		"gold":
			mag = randf_range(0.05, 0.10) * rar.mult
			desc = "+%d%% złota" % round(mag * 100)
		"glint":
			mag = randf_range(0.02, 0.04) * rar.mult
			desc = "+%d%% szans na złoże" % round(mag * 100)
		"reload":
			mag = randf_range(0.05, 0.09) * rar.mult
			desc = "-%d%% czasu zjazdu" % round(mag * 100)
	var defs: Array = part_defs[m]
	var pdef: Dictionary = defs[randi() % defs.size()]
	var cost: float = round(randf_range(25.0, 60.0) * rar.mult)
	return {"name": pdef.name, "machine": machine_names[m], "kind": kind, "desc": desc, "magnitude": mag, "cost": cost, "rarity": rar.name, "rarity_color": rar.color}

func apply_part(part: Dictionary) -> void:
	match part.kind:
		"gold":
			bonus_gold_mult += part.magnitude
		"glint":
			bonus_glint_add += part.magnitude
		"reload":
			bonus_reload_mult = maxf(0.4, bonus_reload_mult - part.magnitude)
