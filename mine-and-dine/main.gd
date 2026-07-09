extends Control
## Mine & Dine — rdzeń "SYP" loop (prototyp gameplayowy, greybox).
## Pętla: SYP -> smyranie (reveal) -> błysk (TWARDY TIMER) -> ZOOM: woda -> wybieranie -> magazyn -> sprzedaż.
## Placeholdery: prostokąty/koła/tweeny. Bez artu — sprawdzamy tylko FEEL pętli.

enum S { IDLE, SHIPMENT, SMYRANIE, REVEALED, ZOOM_CLEAN, ZOOM_PICK, RELOAD, POPUP }

# ---- geometria (design 1080 x 1920) — ruch pionowy góra->dół ----
const LANE_CX := 540.0        # środek toru (poziomo)
const LANE_X := 330.0
const LANE_Y := 250.0
const LANE_W := 420.0
const LANE_H := 1240.0
const PILE_W := 340.0
const PILE_H := 300.0
const PILE_TOP_Y := 300.0     # spawn u góry
const SMYRANIE_Y := 900.0     # parkowanie do smyrania (dół)
const EXIT_Y := 1460.0        # zjazd z toru przy błysku

var state: int = S.IDLE

# nody
var cash_label: Label
var gold_label: Label
var price_label: Label
var sell_button: Button
var belt: Panel
var pile: Panel
var pile_content: Control
var glint: TextureRect
var soil_layer: TextureRect
var _pile_img: Image
var _pile_imgtex: ImageTexture
var _soil_opaque_total := 1
var _soil_opaque_cleared := 0
# błoto w OCZYŚĆ (ten sam mound co ziemia, zmywany wodą maską)
var clean_mud_layer: TextureRect
var _clean_img: Image
var _clean_imgtex: ImageTexture
var _clean_total := 1
var _clean_cleared := 0
var _batch_has_gold := false
var _batch_kind := "empty"   # "gold" | "fake" | "empty"
var _fake_tex: Texture2D
var _gold_preview_pos := Vector2(150, 130)
var hint_label: Label
var syp_button: Button
var syp_cd_bar: ProgressBar
var shake_bar: ProgressBar
# baner działki / cel
var goal_bar: ProgressBar
var goal_label: Label
var plot_title_label: Label
# dolne menu / overlay kopalni
var mine_layer: CanvasLayer
var mine_list_box: VBoxContainer
var mine_detail_box: Control
var mine_title: Label
var current_machine := ""

# tekstury (assety)
var tex_nugget: Texture2D
var tex_waste: Texture2D
var tex_soil: Texture2D
var tex_mud: Texture2D
var tex_glint: Texture2D
var tex_bottle: Texture2D
var tex_mirror: Texture2D

# overlays
var zoom_layer: CanvasLayer
var zoom_bg: TextureRect
var zoom_title: Label
var gold_area: Panel
var mud_tiles: Array = []
var water_cursor: Panel
var water_stream: ColorRect
var done_button: Button
var clean_bar: ProgressBar
var nugget_buttons: Array = []

var popup_layer: CanvasLayer
var toast_layer: CanvasLayer

# runtime
var _pointer_down := false
var _shake := 0.0
var _shake_accum := 0.0
var _pile_speed := 0.0
var _glint_end_y := 0.0
# stamina wody (faza czyszczenia)
var _water_stamina := 1.0
var _water_locked := false
var _last_pointer := Vector2.ZERO
# overlay sprzedaży
var sell_layer: CanvasLayer
var sell_gold_label: Label
var sell_price_label: Label
var sell_value_label: Label
var sell_timer_label: Label
var sell_do_button: Button
var sell_chart: Control
# overlay działek
var plots_layer: CanvasLayer
var plots_box: VBoxContainer
var _idle_timer: Timer
var _batch_gold := 0.0
var _mud_cleared := 0
var _mud_total := 0
var _nuggets_left := 0
var _nuggets_value := 0.0
var _last_price := 60.0
var _price_timer: Timer

func _ready() -> void:
	set_process(true)
	tex_nugget = load("res://assets/nugget_gold.webp")
	tex_waste = load("res://assets/waste_chunk.webp")
	tex_soil = load("res://assets/soil_pile.webp")
	tex_mud = load("res://assets/mud.webp")
	tex_glint = load("res://assets/glint.webp")
	tex_bottle = load("res://assets/junk_bottle.webp")
	tex_mirror = load("res://assets/junk_mirror.webp")
	_build_background()
	_build_hud()
	_build_plot_banner()
	_build_belt()
	_build_syp()
	_build_bottom_nav()
	_build_mine_overlay()
	_build_sell_overlay()
	_build_plots_overlay()
	_build_zoom_layer()
	_build_popup_layer()
	_build_toast_layer()

	_price_timer = Timer.new()
	_price_timer.wait_time = 2.0
	_price_timer.autostart = true
	_price_timer.timeout.connect(func(): GameState.tick_price())
	add_child(_price_timer)

	# idle: pracownicy dodają złoto co sekundę
	_idle_timer = Timer.new()
	_idle_timer.wait_time = 1.0
	_idle_timer.autostart = true
	_idle_timer.timeout.connect(func():
		var r := GameState.idle_rate()
		if r > 0.0:
			GameState.add_raw_gold(r, false)  # idle NIE liczy się do celu
	)
	add_child(_idle_timer)

	GameState.workers_changed.connect(func(): _refresh_plots())
	GameState.cash_changed.connect(_on_cash_changed)
	GameState.raw_gold_changed.connect(_on_gold_changed)
	GameState.price_changed.connect(_on_price_changed)
	GameState.goal_changed.connect(_on_goal_changed)
	GameState.upgraded.connect(func(_m): _refresh_hud(); _refresh_mine())

	_refresh_hud()
	_set_state(S.IDLE)

# =============================================================
#  BUDOWA UI
# =============================================================
func _build_background() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/bg_dig.webp")
	bg.position = Vector2.ZERO
	bg.size = Vector2(1080, 1920)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# delikatna zasłona dla czytelności HUD
	var scrim := ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.18)
	scrim.position = Vector2.ZERO
	scrim.size = Vector2(1080, 1920)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)

func _build_hud() -> void:
	# 3 chipy: złoto (lewo) · kurs (środek) · kasa (prawo)
	gold_label = _make_chip(40, 300, Color(0.95, 0.82, 0.35))
	gold_label.text = "● 0.0 g"
	price_label = _make_chip(370, 340, Color(0.5, 0.95, 0.5))
	price_label.text = "▲ $60/g"
	cash_label = _make_chip(740, 300, Color(0.85, 0.9, 0.95))
	cash_label.text = "$0"

func _build_plot_banner() -> void:
	var panel := Panel.new()
	panel.position = Vector2(30, 104)
	panel.size = Vector2(1020, 150)
	_style_panel(panel, Color(0.13, 0.12, 0.11, 0.94))
	add_child(panel)

	plot_title_label = _mk_label("", 32, Color(0.92, 0.9, 0.85))
	plot_title_label.position = Vector2(20, 14)
	plot_title_label.size = Vector2(980, 44)
	plot_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plot_title_label.text = "%s · DZIAŁKA NR %d" % [GameState.plot_name.to_upper(), GameState.plot_number]
	panel.add_child(plot_title_label)

	goal_bar = ProgressBar.new()
	goal_bar.position = Vector2(30, 66)
	goal_bar.size = Vector2(960, 30)
	goal_bar.min_value = 0.0
	goal_bar.max_value = GameState.plot_goal
	goal_bar.value = 0.0
	goal_bar.show_percentage = false
	_style_progress(goal_bar, Color(0.85, 0.72, 0.30))
	panel.add_child(goal_bar)

	var cel := _mk_label("CEL:", 28, Color(0.7, 0.68, 0.62))
	cel.position = Vector2(30, 104); cel.size = Vector2(300, 38)
	panel.add_child(cel)

	goal_label = _mk_label("0.0 g / %d g" % int(GameState.plot_goal), 28, Color(0.9, 0.85, 0.6))
	goal_label.position = Vector2(490, 104); goal_label.size = Vector2(500, 38)
	goal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(goal_label)

func _build_belt() -> void:
	# pionowy tor (chuta) — półprzezroczysty, na tle fotoreal taśmy
	belt = Panel.new()
	belt.position = Vector2(LANE_X, LANE_Y)
	belt.size = Vector2(LANE_W, LANE_H)
	_style_panel(belt, Color(0.06, 0.05, 0.05, 0.34))
	belt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(belt)

	# hałda (kontener, przezroczysty)
	pile = Panel.new()
	pile.size = Vector2(PILE_W, PILE_H)
	pile.position = Vector2(LANE_CX - PILE_W * 0.5, PILE_TOP_Y)
	pile.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	pile.visible = false
	add_child(pile)

	# zawartość hałdy: pod spodem ruda (złoto+kamienie), na wierzchu ścieralna ziemia
	pile_content = Control.new()
	pile_content.position = Vector2.ZERO
	pile_content.size = Vector2(PILE_W, PILE_H)
	pile_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pile.add_child(pile_content)

	glint = TextureRect.new()
	glint.texture = tex_glint
	glint.size = Vector2(150, 150)
	glint.position = Vector2(PILE_W * 0.5 - 75, PILE_H * 0.5 - 75)
	glint.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glint.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	glint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glint.visible = false
	pile.add_child(glint)

	shake_bar = ProgressBar.new()
	shake_bar.position = Vector2(270, 1250)
	shake_bar.size = Vector2(540, 28)
	shake_bar.min_value = 0
	shake_bar.max_value = 1.0
	shake_bar.value = 0
	shake_bar.show_percentage = false
	shake_bar.visible = false
	_style_progress(shake_bar, Color(0.85, 0.72, 0.30))
	add_child(shake_bar)

	hint_label = _mk_label("", 32, Color(0.95, 0.9, 0.7))
	hint_label.position = Vector2(90, 1292)
	hint_label.size = Vector2(900, 46)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint_label)

func _build_syp() -> void:
	syp_button = Button.new()
	syp_button.text = "SYP"
	syp_button.position = Vector2(280, 1552)
	syp_button.size = Vector2(520, 200)
	_style_industrial_button(syp_button, 80)
	syp_button.pressed.connect(_on_syp)
	add_child(syp_button)

	syp_cd_bar = ProgressBar.new()
	syp_cd_bar.position = Vector2(280, 1534)
	syp_cd_bar.size = Vector2(520, 14)
	syp_cd_bar.min_value = 0
	syp_cd_bar.max_value = 1.0
	syp_cd_bar.value = 0
	syp_cd_bar.show_percentage = false
	syp_cd_bar.visible = false
	_style_progress(syp_cd_bar, Color(0.85, 0.72, 0.30))
	add_child(syp_cd_bar)

func _build_bottom_nav() -> void:
	var bar := Panel.new()
	bar.position = Vector2(0, 1770)
	bar.size = Vector2(1080, 150)
	_style_panel(bar, Color(0.10, 0.09, 0.08))
	add_child(bar)

	var w := 270.0
	var manage := _make_nav_tab(0 * w, w, "MASZYNY", Color(0.75, 0.78, 0.85))
	manage.pressed.connect(_open_mine)

	var dig := _make_nav_tab(1 * w, w, "KOP", Color(0.95, 0.82, 0.35))
	dig.pressed.connect(_close_overlays)

	sell_button = _make_nav_tab(2 * w, w, "SPRZEDAJ", Color(0.5, 0.95, 0.5))
	sell_button.pressed.connect(_open_sell)

	var plots := _make_nav_tab(3 * w, w, "DZIAŁKI", Color(0.6, 0.8, 1.0))
	plots.pressed.connect(_open_plots)

func _close_overlays() -> void:
	if mine_layer: mine_layer.visible = false
	if sell_layer: sell_layer.visible = false
	if plots_layer: plots_layer.visible = false

func _make_nav_tab(x: float, w: float, label: String, accent: Color) -> Button:
	var b := Button.new()
	b.position = Vector2(x, 1772)
	b.size = Vector2(w, 148)
	b.flat = true
	b.text = label
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 34)
	b.add_theme_color_override("font_color", Color(0.9, 0.88, 0.85))
	b.add_theme_color_override("font_disabled_color", Color(0.45, 0.43, 0.4))
	add_child(b)
	var accent_bar := ColorRect.new()
	accent_bar.color = accent
	accent_bar.position = Vector2(x + w * 0.5 - 55, 1786)
	accent_bar.size = Vector2(110, 6)
	accent_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(accent_bar)
	return b

# ---------------- SPRZEDAŻ (popup) ----------------
func _build_sell_overlay() -> void:
	sell_layer = CanvasLayer.new()
	sell_layer.layer = 16
	sell_layer.visible = false
	add_child(sell_layer)
	var dim := Panel.new()
	dim.position = Vector2.ZERO
	dim.size = Vector2(1080, 1920)
	_style_panel(dim, Color(0.05, 0.05, 0.06, 0.88))
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	sell_layer.add_child(dim)
	var box := Panel.new()
	box.position = Vector2(100, 470)
	box.size = Vector2(880, 970)
	_style_panel(box, Color(0.14, 0.14, 0.13))
	sell_layer.add_child(box)
	var t := _mk_label("SPRZEDAŻ ZŁOTA", 46, Color(0.95, 0.85, 0.4))
	t.position = Vector2(120, 500); t.size = Vector2(840, 60)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sell_layer.add_child(t)
	# wykres giełdowy kursu
	var chart_frame := Panel.new()
	chart_frame.position = Vector2(150, 582); chart_frame.size = Vector2(780, 258)
	_style_panel(chart_frame, Color(0.07, 0.06, 0.06))
	sell_layer.add_child(chart_frame)
	sell_chart = Control.new()
	sell_chart.position = Vector2(158, 590); sell_chart.size = Vector2(764, 242)
	sell_chart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sell_chart.draw.connect(_draw_price_chart.bind(sell_chart))
	sell_layer.add_child(sell_chart)
	sell_gold_label = _mk_label("", 38, Color(0.95, 0.82, 0.35))
	sell_gold_label.position = Vector2(170, 862); sell_gold_label.size = Vector2(740, 50)
	sell_layer.add_child(sell_gold_label)
	sell_price_label = _mk_label("", 38, Color(0.85, 0.9, 0.95))
	sell_price_label.position = Vector2(170, 918); sell_price_label.size = Vector2(740, 50)
	sell_layer.add_child(sell_price_label)
	sell_value_label = _mk_label("", 44, Color(0.5, 0.95, 0.5))
	sell_value_label.position = Vector2(170, 974); sell_value_label.size = Vector2(740, 56)
	sell_layer.add_child(sell_value_label)
	sell_timer_label = _mk_label("", 28, Color(0.7, 0.7, 0.72))
	sell_timer_label.position = Vector2(170, 1036); sell_timer_label.size = Vector2(740, 40)
	sell_layer.add_child(sell_timer_label)
	sell_do_button = Button.new()
	sell_do_button.text = "SPRZEDAJ WSZYSTKO"
	sell_do_button.position = Vector2(170, 1100); sell_do_button.size = Vector2(740, 120)
	_style_industrial_button(sell_do_button, 42)
	sell_do_button.pressed.connect(func(): _on_sell(); _refresh_sell())
	sell_layer.add_child(sell_do_button)
	# drugi, mniej ważny przycisk — wróć do kopania
	var dig_more := Button.new()
	dig_more.text = "KOP DALEJ"
	dig_more.position = Vector2(170, 1234); dig_more.size = Vector2(740, 92)
	_style_button(dig_more, 36)
	dig_more.pressed.connect(func(): _close_overlays())
	sell_layer.add_child(dig_more)
	var close := Button.new()
	close.text = "✕"; close.position = Vector2(870, 482); close.size = Vector2(90, 90)
	_style_button(close, 44)
	close.pressed.connect(func(): sell_layer.visible = false)
	sell_layer.add_child(close)

func _open_sell() -> void:
	_close_overlays()
	sell_layer.visible = true
	_refresh_sell()

func _refresh_sell() -> void:
	if sell_layer == null or not sell_layer.visible:
		return
	var g := GameState.raw_gold
	sell_gold_label.text = "Złoto w magazynie: %.1f g" % g
	sell_price_label.text = "Aktualny kurs: $%d / g" % int(round(GameState.price))
	sell_value_label.text = "Wartość: $%d" % int(round(g * GameState.price))
	sell_do_button.disabled = g <= 0.0
	if sell_chart:
		sell_chart.queue_redraw()

func _draw_price_chart(c: Control) -> void:
	var hist: Array = GameState.price_history
	var sz := c.size
	if hist.size() < 2:
		return
	var lo := GameState.price_min
	var hi := GameState.price_max
	var span: float = maxf(1.0, hi - lo)
	var n := hist.size()
	# siatka pozioma + etykiety skrajne
	for gi in range(1, 4):
		var gy := sz.y * gi / 4.0
		c.draw_line(Vector2(0, gy), Vector2(sz.x, gy), Color(1, 1, 1, 0.07), 1.0)
	var pts := PackedVector2Array()
	for i in range(n):
		var x := sz.x * float(i) / float(n - 1)
		var y := sz.y - (float(hist[i]) - lo) / span * sz.y
		pts.append(Vector2(x, y))
	var up: bool = float(hist[n - 1]) >= float(hist[0])
	var col := Color(0.4, 0.9, 0.5) if up else Color(0.95, 0.45, 0.45)
	# wypełnienie pod krzywą
	var fill := PackedVector2Array(pts)
	fill.append(Vector2(sz.x, sz.y))
	fill.append(Vector2(0, sz.y))
	c.draw_colored_polygon(fill, Color(col.r, col.g, col.b, 0.12))
	c.draw_polyline(pts, col, 3.0, true)
	c.draw_circle(pts[n - 1], 7.0, col)

# ---------------- DZIAŁKI (lokacje + pracownicy) ----------------
func _build_plots_overlay() -> void:
	plots_layer = CanvasLayer.new()
	plots_layer.layer = 16
	plots_layer.visible = false
	add_child(plots_layer)
	var bg := Panel.new()
	bg.position = Vector2.ZERO
	bg.size = Vector2(1080, 1920)
	_style_panel(bg, Color(0.08, 0.07, 0.06, 0.99))
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	plots_layer.add_child(bg)
	var t := _mk_label("DZIAŁKI — Lokacje", 46, Color(0.6, 0.8, 1.0))
	t.position = Vector2(60, 70); t.size = Vector2(800, 60)
	plots_layer.add_child(t)
	var close := Button.new()
	close.text = "✕"; close.position = Vector2(920, 55); close.size = Vector2(110, 100)
	_style_button(close, 48)
	close.pressed.connect(func(): plots_layer.visible = false)
	plots_layer.add_child(close)
	plots_box = VBoxContainer.new()
	plots_box.position = Vector2(50, 190); plots_box.size = Vector2(980, 1540)
	plots_box.add_theme_constant_override("separation", 26)
	plots_layer.add_child(plots_box)

func _open_plots() -> void:
	_close_overlays()
	plots_layer.visible = true
	_refresh_plots()

func _refresh_plots() -> void:
	if plots_box == null or plots_layer == null or not plots_layer.visible:
		return
	_clear_children(plots_box)
	for loc in GameState.locations:
		var card := Panel.new()
		card.custom_minimum_size = Vector2(980, 420)
		_style_panel(card, Color(0.15, 0.14, 0.13))
		plots_box.add_child(card)

		var name_lbl := _mk_label(loc.name, 42, Color(0.95, 0.9, 0.8))
		name_lbl.position = Vector2(30, 20); name_lbl.size = Vector2(600, 54)
		card.add_child(name_lbl)

		if not loc.unlocked:
			var lock := _mk_label("Zablokowana", 32, Color(0.85, 0.6, 0.5))
			lock.position = Vector2(30, 90); lock.size = Vector2(600, 44)
			card.add_child(lock)
			var unlock := Button.new()
			unlock.text = "ODBLOKUJ   $%d" % int(GameState.unlock_cost(loc.id))
			unlock.position = Vector2(30, 160); unlock.size = Vector2(700, 130)
			_style_industrial_button(unlock, 40)
			unlock.disabled = GameState.cash < GameState.unlock_cost(loc.id)
			unlock.pressed.connect(_on_unlock_location.bind(loc.id))
			card.add_child(unlock)
		else:
			var st := _mk_label("Pracownicy IDLE: %d / %d   (+%.2f g/min)" % [GameState.worker_count(loc.id), GameState.MAX_WORKERS, GameState.worker_count(loc.id) * GameState.IDLE_G_PER_WORKER_PER_MIN], 30, Color(0.7, 0.85, 1.0))
			st.position = Vector2(30, 84); st.size = Vector2(920, 40)
			card.add_child(st)
			for i in range(GameState.MAX_WORKERS):
				var filled: bool = i < GameState.worker_count(loc.id)
				var slot := Panel.new()
				slot.position = Vector2(30 + i * 130, 140); slot.size = Vector2(110, 110)
				_style_panel(slot, Color(0.85, 0.72, 0.30) if filled else Color(0.22, 0.21, 0.20))
				card.add_child(slot)
				var icon := _mk_label("●" if filled else "+", 46, Color(0.12, 0.10, 0.06) if filled else Color(0.5, 0.5, 0.5))
				icon.position = Vector2(30 + i * 130, 148); icon.size = Vector2(110, 94)
				icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				card.add_child(icon)
			var buy := Button.new()
			if GameState.worker_count(loc.id) >= GameState.MAX_WORKERS:
				buy.text = "KOMPLET"
				buy.disabled = true
			else:
				buy.text = "ZATRUDNIJ   $%d" % int(GameState.worker_cost(loc.id))
				buy.disabled = not GameState.can_buy_worker(loc.id)
			buy.position = Vector2(30, 280); buy.size = Vector2(700, 120)
			_style_button(buy, 38)
			buy.pressed.connect(_on_buy_worker.bind(loc.id))
			card.add_child(buy)

func _on_unlock_location(id: String) -> void:
	if GameState.unlock_location(id):
		_toast("Odblokowano lokację!", Color(0.6, 0.9, 0.7))
		_refresh_plots()

func _on_buy_worker(id: String) -> void:
	if GameState.buy_worker(id):
		_toast("Zatrudniono pracownika", Color(0.7, 0.85, 1.0))
		_refresh_plots()

func _build_mine_overlay() -> void:
	mine_layer = CanvasLayer.new()
	mine_layer.layer = 15
	mine_layer.visible = false
	add_child(mine_layer)

	var bg := Panel.new()
	bg.position = Vector2.ZERO
	bg.size = Vector2(1080, 1920)
	_style_panel(bg, Color(0.08, 0.07, 0.06, 0.99))
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	mine_layer.add_child(bg)

	mine_title = _mk_label("KOPALNIA — Maszyny", 46, Color(0.95, 0.85, 0.4))
	mine_title.position = Vector2(60, 70)
	mine_title.size = Vector2(800, 60)
	mine_layer.add_child(mine_title)

	var close := Button.new()
	close.text = "✕"
	close.position = Vector2(920, 55)
	close.size = Vector2(110, 100)
	_style_button(close, 48)
	close.pressed.connect(func(): mine_layer.visible = false)
	mine_layer.add_child(close)

	mine_list_box = VBoxContainer.new()
	mine_list_box.position = Vector2(60, 200)
	mine_list_box.size = Vector2(960, 1520)
	mine_list_box.add_theme_constant_override("separation", 20)
	mine_layer.add_child(mine_list_box)

	mine_detail_box = Control.new()
	mine_detail_box.position = Vector2.ZERO
	mine_detail_box.size = Vector2(1080, 1920)
	mine_detail_box.visible = false
	mine_layer.add_child(mine_detail_box)

func _open_mine() -> void:
	mine_layer.visible = true
	_show_machine_list()

func _show_machine_list() -> void:
	mine_title.text = "KOPALNIA — Maszyny"
	mine_detail_box.visible = false
	mine_list_box.visible = true
	_clear_children(mine_list_box)
	for m in GameState.order:
		var b := Button.new()
		b.custom_minimum_size = Vector2(960, 150)
		_style_button(b, 34)
		b.text = "%s    ·    moc %d   ›\n%s" % [GameState.machine_names[m], GameState.machine_level(m), GameState.machine_role[m]]
		b.pressed.connect(_show_machine_detail.bind(m))
		mine_list_box.add_child(b)

func _show_machine_detail(m: String) -> void:
	current_machine = m
	mine_list_box.visible = false
	mine_detail_box.visible = true
	mine_title.text = "%s — części" % GameState.machine_names[m]
	_clear_children(mine_detail_box)

	var back := Button.new()
	back.text = "‹  Wróć"
	back.position = Vector2(60, 150)
	back.size = Vector2(260, 90)
	_style_button(back, 34)
	back.pressed.connect(_show_machine_list)
	mine_detail_box.add_child(back)

	var vbox := VBoxContainer.new()
	vbox.position = Vector2(60, 270)
	vbox.size = Vector2(960, 1450)
	vbox.add_theme_constant_override("separation", 16)
	mine_detail_box.add_child(vbox)

	for p in GameState.part_defs[m]:
		var key: String = p.key
		var locked: bool = GameState.is_locked(m, key)
		var row := Panel.new()
		row.custom_minimum_size = Vector2(960, 200)
		_style_panel(row, Color(0.12, 0.11, 0.10) if locked else Color(0.16, 0.15, 0.13))
		if locked:
			row.modulate = Color(0.6, 0.6, 0.6)
		vbox.add_child(row)

		var nm := _mk_label(p.name, 38, Color(0.95, 0.9, 0.8))
		nm.position = Vector2(30, 18); nm.size = Vector2(600, 46)
		row.add_child(nm)

		var lvl: int = GameState.part_level(m, key)
		var eff := _mk_label(GameState.part_effect_text(m, key), 30, Color(0.7, 0.85, 1.0))
		eff.position = Vector2(30, 76); eff.size = Vector2(600, 40)
		row.add_child(eff)

		if not locked:
			var lvll := _mk_label("Lvl %d" % lvl, 26, Color(0.55, 0.8, 0.55))
			lvll.position = Vector2(30, 126); lvll.size = Vector2(600, 36)
			row.add_child(lvll)

		var buy := Button.new()
		buy.position = Vector2(660, 40); buy.size = Vector2(270, 120)
		_style_button(buy, 32)
		if locked:
			buy.text = "⚙\nwkrótce"
			buy.disabled = true
		else:
			var cost := GameState.part_cost(m, key)
			buy.text = "ULEPSZ\n$%d" % int(cost)
			buy.disabled = GameState.cash < cost
			buy.pressed.connect(_on_upgrade_part.bind(m, key))
		row.add_child(buy)

func _build_zoom_layer() -> void:
	zoom_layer = CanvasLayer.new()
	zoom_layer.layer = 10
	zoom_layer.visible = false
	add_child(zoom_layer)

	zoom_bg = TextureRect.new()
	zoom_bg.texture = load("res://assets/bg_sluice.webp")
	zoom_bg.position = Vector2.ZERO
	zoom_bg.size = Vector2(1080, 1920)
	zoom_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	zoom_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	zoom_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	zoom_layer.add_child(zoom_bg)
	var zscrim := ColorRect.new()
	zscrim.color = Color(0, 0, 0, 0.38)
	zscrim.position = Vector2.ZERO
	zscrim.size = Vector2(1080, 1920)
	zscrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zoom_layer.add_child(zscrim)

	zoom_title = _mk_label("", 52, Color(0.95, 0.9, 0.6))
	zoom_title.position = Vector2(60, 220)
	zoom_title.size = Vector2(960, 70)
	zoom_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zoom_layer.add_child(zoom_title)

	# obszar ze złotem (pod błotem)
	gold_area = Panel.new()
	gold_area.position = Vector2(160, 520)
	gold_area.size = Vector2(760, 760)
	gold_area.add_theme_stylebox_override("panel", StyleBoxEmpty.new())  # przezroczyste — widać sluice
	zoom_layer.add_child(gold_area)

	# struga wody z góry (za kursorem)
	water_stream = ColorRect.new()
	water_stream.color = Color(0.5, 0.8, 1.0, 0.30)
	water_stream.visible = false
	water_stream.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zoom_layer.add_child(water_stream)

	# okrągły "rozbryzg" wody podążający za palcem
	water_cursor = Panel.new()
	water_cursor.size = Vector2(130, 130)
	var wsb := StyleBoxFlat.new()
	wsb.bg_color = Color(0.45, 0.78, 1.0, 0.45)
	wsb.set_corner_radius_all(65)
	water_cursor.add_theme_stylebox_override("panel", wsb)
	water_cursor.visible = false
	water_cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zoom_layer.add_child(water_cursor)
	var wcore := Panel.new()
	wcore.size = Vector2(54, 54)
	wcore.position = Vector2(38, 38)
	var wcsb := StyleBoxFlat.new()
	wcsb.bg_color = Color(0.9, 0.97, 1.0, 0.7)
	wcsb.set_corner_radius_all(27)
	wcore.add_theme_stylebox_override("panel", wcsb)
	wcore.mouse_filter = Control.MOUSE_FILTER_IGNORE
	water_cursor.add_child(wcore)

	done_button = Button.new()
	done_button.text = "GOTOWE"
	done_button.position = Vector2(340, 1400)
	done_button.size = Vector2(400, 140)
	_style_button(done_button, 48)
	done_button.pressed.connect(_on_pick_done)
	done_button.visible = false
	zoom_layer.add_child(done_button)

	clean_bar = ProgressBar.new()
	clean_bar.position = Vector2(160, 1500)
	clean_bar.size = Vector2(760, 44)
	clean_bar.min_value = 0.0
	clean_bar.max_value = 1.0
	clean_bar.value = 0.0
	clean_bar.show_percentage = false
	clean_bar.visible = false
	_style_progress(clean_bar, Color(0.5, 0.8, 1.0))
	zoom_layer.add_child(clean_bar)

func _build_popup_layer() -> void:
	popup_layer = CanvasLayer.new()
	popup_layer.layer = 20
	popup_layer.visible = false
	add_child(popup_layer)

func _build_toast_layer() -> void:
	toast_layer = CanvasLayer.new()
	toast_layer.layer = 30
	add_child(toast_layer)

# =============================================================
#  STATE MACHINE
# =============================================================
func _set_state(s: int) -> void:
	state = s
	match s:
		S.IDLE:
			syp_button.disabled = false
			syp_button.modulate = Color.WHITE
			syp_button.text = "SYP"
			hint_label.text = "Naciśnij SYP, żeby nasypać hałdę"
			shake_bar.visible = false
			syp_cd_bar.visible = false
		S.SHIPMENT:
			syp_button.disabled = true
			syp_button.text = "SYP"
			hint_label.text = "Ziemia jedzie w dół..."
			shake_bar.visible = false
		S.SMYRANIE:
			syp_button.disabled = true
			hint_label.text = "SMYRAJ palcem po hałdzie! (strząśnij grudy)"
			shake_bar.visible = true
		S.REVEALED:
			syp_button.disabled = false
			syp_button.modulate = Color.WHITE
			syp_button.text = "OCZYŚĆ"
			hint_label.text = "Złoże znalezione! Naciśnij OCZYŚĆ"
			shake_bar.visible = false
		S.RELOAD:
			syp_button.disabled = true
			syp_button.text = "SYP"
			hint_label.text = "Przeładunek wywrotki..."
			syp_cd_bar.visible = true

func _on_syp() -> void:
	if state == S.REVEALED:
		_begin_clean()  # przycisk działa teraz jako OCZYŚĆ
		return
	if state != S.IDLE:
		return
	# wylosuj wynik z góry: coś błyszczy (złoto ALBO fałszywy alarm) lub pusto
	if randf() < GameState.glint_chance():
		if randf() < 0.28:
			_batch_kind = "fake"
			_fake_tex = tex_bottle if randf() < 0.5 else tex_mirror
		else:
			_batch_kind = "gold"
	else:
		_batch_kind = "empty"
	_batch_has_gold = _batch_kind == "gold"
	shake_bar.value = 0.0
	# skala hałdy zależna od łyżki koparki
	pile.size = Vector2(PILE_W, PILE_H) * GameState.pile_scale()
	pile.position = Vector2(LANE_CX - pile.size.x * 0.5, PILE_TOP_Y)
	pile_content.size = pile.size
	_build_pile_content()
	pile.visible = true
	pile.modulate = Color.WHITE
	glint.visible = false
	# zjazd z góry na dół (shipment) — pasek pokazuje CZAS zjazdu (tempo wywrotki)
	_set_state(S.SHIPMENT)
	var t := maxf(0.7, GameState.reload_time())
	syp_cd_bar.value = 0.0
	syp_cd_bar.visible = true
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(pile, "position:y", SMYRANIE_Y, t).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(syp_cd_bar, "value", 1.0, t)
	tw.chain().tween_callback(func():
		syp_cd_bar.visible = false
		if state == S.SHIPMENT:
			_set_state(S.SMYRANIE)
	)

func _reveal() -> void:
	# loot popup po zdarciu ziemi — jeśli wypadnie, rozstrzygnięcie po jego zamknięciu
	if randf() < 0.28:
		_show_loot_popup()
	else:
		_resolve_reveal()

func _resolve_reveal() -> void:
	# wynik wylosowany przy SYP; coś błyszczy (złoto/śmieć) albo pusto
	if _batch_kind != "empty":
		_found_gold()
	else:
		_no_gold()

func _found_gold() -> void:
	# złoże znalezione — przetrzyj dziurę nad złotem (kawałek wystaje) + błysk, przycisk -> OCZYŚĆ
	_reveal_gold_peek()
	glint.position = _gold_preview_pos - glint.size * 0.5
	glint.visible = true
	_set_state(S.REVEALED)

func _reveal_gold_peek() -> void:
	# usuń ziemię nad złotem, by odrobina złota wystawała spod hałdy
	if soil_layer == null or _pile_img == null:
		return
	var iw := _pile_img.get_width()
	var ih := _pile_img.get_height()
	var lx := int(_gold_preview_pos.x / soil_layer.size.x * iw)
	var ly := int(_gold_preview_pos.y / soil_layer.size.y * ih)
	var rad := 10  # malutka dziurka — tylko odrobina wystaje
	var changed := false
	for y in range(maxi(0, ly - rad), mini(ih, ly + rad)):
		for x in range(maxi(0, lx - rad), mini(iw, lx + rad)):
			var dx := x - lx
			var dy := y - ly
			if dx * dx + dy * dy <= rad * rad:
				var col := _pile_img.get_pixel(x, y)
				if col.a > 0.3:
					col.a = 0.0
					_pile_img.set_pixel(x, y, col)
					changed = true
	if changed:
		_pile_imgtex.update(_pile_img)

func _build_pile_content() -> void:
	for ch in pile_content.get_children():
		ch.free()  # natychmiast (queue_free jest odroczone -> zostawałaby stara ruda)
	var w := pile_content.size.x
	var h := pile_content.size.y
	var cen := Vector2(w * 0.5, h * 0.5)

	# WARSTWA BŁOTA pod ziemią (kształt mounda) — odsłaniana smyraniem, usuwana wodą w OCZYŚĆ.
	# Kamienie i złoto są GŁĘBIEJ (pod błotem) — pojawiają się dopiero w etapie oczyszczania.
	var mud := _texrect(tex_soil, Vector2(w, h), TextureRect.STRETCH_SCALE)
	mud.position = Vector2.ZERO
	mud.modulate = Color(0.34, 0.27, 0.18)  # ciemne, wilgotne błoto
	pile_content.add_child(mud)

	# odrobina błyszczącego przebijająca przez błoto (złoto ALBO śmieć) — tu siada błysk
	if _batch_kind != "empty":
		_gold_preview_pos = cen + Vector2(randf_range(-w * 0.07, w * 0.07), randf_range(-h * 0.04, h * 0.10))
		var gs := randf_range(26.0, 40.0)  # tylko malutki kawałek wystaje
		var ptex: Texture2D = tex_nugget if _batch_kind == "gold" else _fake_tex
		var g := _texrect(ptex, Vector2(gs, gs))
		g.position = _gold_preview_pos - Vector2(gs, gs) * 0.5
		g.modulate = Color(0.72, 0.64, 0.46) if _batch_kind == "gold" else Color(0.66, 0.66, 0.62)
		pile_content.add_child(g)
	else:
		_gold_preview_pos = cen

	# warstwa ZIEMI = pojedyncza grafika hałdy z maską alfa (ścierana palcem)
	_pile_img = Image.new()
	_pile_img.copy_from(tex_soil.get_image())
	if _pile_img.get_format() != Image.FORMAT_RGBA8:
		_pile_img.convert(Image.FORMAT_RGBA8)
	var mw := 150
	var mh := int(150.0 * _pile_img.get_height() / _pile_img.get_width())
	_pile_img.resize(mw, mh, Image.INTERPOLATE_BILINEAR)
	_soil_opaque_total = 0
	for y in range(mh):
		for x in range(mw):
			if _pile_img.get_pixel(x, y).a > 0.3:
				_soil_opaque_total += 1
	_soil_opaque_total = maxi(1, _soil_opaque_total)
	_soil_opaque_cleared = 0
	_pile_imgtex = ImageTexture.create_from_image(_pile_img)
	soil_layer = _texrect(_pile_imgtex, Vector2(w, h), TextureRect.STRETCH_SCALE)
	soil_layer.position = Vector2.ZERO
	pile_content.add_child(soil_layer)

func _erode_soil_at(p: Vector2) -> void:
	if soil_layer == null or _pile_img == null:
		return
	# grafika jest wyśrodkowana z zachowaniem proporcji — policz jej realny rect w soil_layer
	var iw := _pile_img.get_width()
	var ih := _pile_img.get_height()
	var ix := int((p.x - soil_layer.global_position.x) / soil_layer.size.x * iw)
	var iy := int((p.y - soil_layer.global_position.y) / soil_layer.size.y * ih)
	var rad := 15
	var changed := false
	for y in range(maxi(0, iy - rad), mini(ih, iy + rad)):
		for x in range(maxi(0, ix - rad), mini(iw, ix + rad)):
			var dx := x - ix
			var dy := y - iy
			if dx * dx + dy * dy <= rad * rad:
				var col := _pile_img.get_pixel(x, y)
				if col.a > 0.3:
					col.a = 0.0
					_pile_img.set_pixel(x, y, col)
					_soil_opaque_cleared += 1
					changed = true
	if changed:
		_pile_imgtex.update(_pile_img)
		_spawn_clump(p)
	shake_bar.value = float(_soil_opaque_cleared) / float(_soil_opaque_total)
	if float(_soil_opaque_cleared) / float(_soil_opaque_total) >= 0.68:
		_reveal()

func _begin_clean() -> void:
	# akcja przycisku OCZYŚĆ
	if state != S.REVEALED:
		return
	_flash(glint.get_global_rect().get_center(), Color(1, 1, 0.5))
	_fade_hide(glint)
	_fade_hide(pile)
	_enter_zoom_clean()

func _no_gold() -> void:
	_fade_hide(glint)
	_fade_hide(pile)
	_toast("Pusto — sama ziemia", Color(0.7, 0.7, 0.7))
	_start_reload()

func _start_reload() -> void:
	# koniec partii — od razu gotowy na SYP (czekanie jest teraz z przodu, przy zjeździe)
	_set_state(S.IDLE)

# =============================================================
#  ZOOM: czyszczenie wodą -> wybieranie
# =============================================================
func _enter_zoom_clean() -> void:
	_set_state(S.ZOOM_CLEAN)
	zoom_title.text = "PŁUCZ WODĄ — zmyj błoto ze złota"
	done_button.visible = false
	water_cursor.visible = false
	water_stream.visible = false
	_clear_children(gold_area)
	mud_tiles.clear()
	nugget_buttons.clear()
	_nuggets_value = GameState.gold_per_nugget()

	var cen := Vector2(380.0, 380.0)  # środek obszaru 760x760

	# 1) DUŻO małych kamieni rozsypanych po całym polu (na spodzie — złoto i tak jest nad nimi)
	for i in range(randi_range(32, 46)):
		var ws := randf_range(50.0, 92.0)
		var w := _texrect(tex_waste, Vector2(ws, ws))
		var a := randf() * TAU
		var rad := randf_range(0.0, 320.0)
		w.position = cen + Vector2(cos(a) * rad, sin(a) * rad) - Vector2(ws, ws) * 0.5
		gold_area.add_child(w)

	# 2) złoto (gdy złoże) albo śmieć — NAD kamieniami, zawsze widoczne do wybrania
	if _batch_kind == "fake":
		_nuggets_left = 0
		var js := randf_range(190.0, 250.0)
		var j := _texrect(_fake_tex, Vector2(js, js))
		j.position = cen - Vector2(js, js) * 0.5
		gold_area.add_child(j)
	else:
		var n := GameState.nugget_count()
		if randf() < GameState.bonus_nugget_chance():
			n += 1
		for i in range(n):
			var b := _make_nugget()
			var s: float = b.size.x
			var a := randf() * TAU
			var rad := randf_range(0.0, 260.0)  # złoto losowo po całym polu (i tak rysowane NA WIERZCHU)
			b.position = cen + Vector2(cos(a) * rad, sin(a) * rad) - Vector2(s, s) * 0.5
			gold_area.add_child(b)
			nugget_buttons.append(b)
		_nuggets_left = n

	# 3) BŁOTO na wierzchu — TEN SAM mulisty mound co w smyraniu (spójnie), zmywany wodą maską
	mud_tiles.clear()
	_clean_img = Image.new()
	_clean_img.copy_from(tex_soil.get_image())
	if _clean_img.get_format() != Image.FORMAT_RGBA8:
		_clean_img.convert(Image.FORMAT_RGBA8)
	var cmw := 200
	var cmh := int(200.0 * _clean_img.get_height() / _clean_img.get_width())
	_clean_img.resize(cmw, cmh, Image.INTERPOLATE_BILINEAR)
	_clean_total = 0
	for y in range(cmh):
		for x in range(cmw):
			if _clean_img.get_pixel(x, y).a > 0.3:
				_clean_total += 1
	_clean_total = maxi(1, _clean_total)
	_clean_cleared = 0
	_clean_imgtex = ImageTexture.create_from_image(_clean_img)
	clean_mud_layer = _texrect(_clean_imgtex, gold_area.size, TextureRect.STRETCH_SCALE)
	clean_mud_layer.position = Vector2.ZERO
	clean_mud_layer.modulate = Color(0.34, 0.27, 0.18)  # ten sam ton błota co w smyraniu
	gold_area.add_child(clean_mud_layer)
	# pasek = STAMINA wody (nie progres) — start pełny
	_water_stamina = 1.0
	_water_locked = false
	clean_bar.value = 1.0
	clean_bar.modulate = Color.WHITE
	clean_bar.visible = true
	_fade_in_layer(zoom_layer)  # płynne wejście w zoom

func _clean_at(global_pos: Vector2, _dt: float) -> void:
	water_cursor.visible = true
	water_cursor.global_position = global_pos - water_cursor.size * 0.5
	_update_water_stream(global_pos)
	if clean_mud_layer == null or _clean_img == null:
		return
	var iw := _clean_img.get_width()
	var ih := _clean_img.get_height()
	var ix := int((global_pos.x - clean_mud_layer.global_position.x) / clean_mud_layer.size.x * iw)
	var iy := int((global_pos.y - clean_mud_layer.global_position.y) / clean_mud_layer.size.y * ih)
	var rad := maxi(6, int(GameState.water_radius() / clean_mud_layer.size.x * iw))
	var changed := false
	for y in range(maxi(0, iy - rad), mini(ih, iy + rad)):
		for x in range(maxi(0, ix - rad), mini(iw, ix + rad)):
			var dx := x - ix
			var dy := y - iy
			if dx * dx + dy * dy <= rad * rad:
				var col := _clean_img.get_pixel(x, y)
				if col.a > 0.3:
					col.a = 0.0
					_clean_img.set_pixel(x, y, col)
					_clean_cleared += 1
					changed = true
	if changed:
		_clean_imgtex.update(_clean_img)
		_spawn_mud_fleck(global_pos)
	if float(_clean_cleared) / float(_clean_total) >= 0.86:
		_enter_zoom_pick()

func _update_water_stamina(dt: float) -> void:
	if _water_locked:
		# blokada: regeneracja 0->100% w 5s, dopiero wtedy odblokowanie
		_water_stamina = minf(1.0, _water_stamina + (1.0 / 5.0) * dt)
		water_cursor.visible = false
		water_stream.visible = false
		if _water_stamina >= 1.0:
			_water_locked = false
	elif _pointer_down and _water_stamina > 0.0:
		_water_stamina = maxf(0.0, _water_stamina - 0.21 * dt)
		_clean_at(_last_pointer, dt)
		if _water_stamina <= 0.0:
			_water_locked = true
			water_cursor.visible = false
			water_stream.visible = false
			_toast("Brak wody! Regeneracja 5s", Color(1, 0.5, 0.4))
	else:
		_water_stamina = minf(1.0, _water_stamina + 0.40 * dt)
		water_cursor.visible = false
		water_stream.visible = false
	clean_bar.value = _water_stamina
	clean_bar.modulate = Color(1.0, 0.45, 0.4) if _water_locked else Color.WHITE

func _enter_zoom_pick() -> void:
	if state == S.ZOOM_PICK:
		return
	_set_state(S.ZOOM_PICK)
	water_cursor.visible = false
	water_stream.visible = false
	clean_bar.visible = false
	_fade_hide(clean_mud_layer)  # błoto znika płynnie, odsłania kamienie+złoto
	if _batch_kind == "fake":
		# fałszywy alarm — to był tylko śmieć, nie ma czego zbierać
		zoom_title.text = "FAŁSZYWY ALARM! To tylko śmieć…"
		_toast("Fałszywy alarm!", Color(1, 0.6, 0.4))
		done_button.text = "SZKODA…"
		done_button.visible = true
		return
	zoom_title.text = "WYBIERZ ZŁOTO — tapnij grudki"
	# TE SAME grudki + delikatny puls "weź mnie" (trafianie w _pointer_press po promieniu)
	for b in nugget_buttons:
		if is_instance_valid(b):
			var tw := create_tween().set_loops()
			tw.tween_property(b, "scale", Vector2(1.18, 1.18), 0.45)
			tw.tween_property(b, "scale", Vector2(1.0, 1.0), 0.45)
			b.set_meta("pulse", tw)
	done_button.text = "ZBIERZ RESZTĘ"
	done_button.visible = true

func _make_nugget() -> TextureRect:
	var s := randf_range(88.0, 122.0)
	var b := _texrect(tex_nugget, Vector2(s, s))
	b.pivot_offset = Vector2(s * 0.5, s * 0.5)  # puls z centrum
	return b

func _spawn_mud_fleck(pos: Vector2) -> void:
	for i in range(2):
		var f := ColorRect.new()
		f.size = Vector2(16, 16)
		f.color = Color(0.30, 0.22, 0.12)
		f.global_position = pos
		f.mouse_filter = Control.MOUSE_FILTER_IGNORE
		zoom_layer.add_child(f)
		var dir := Vector2(randf_range(-90, 90), randf_range(50, 170))
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(f, "position", f.position + dir, 0.4)
		tw.tween_property(f, "modulate:a", 0.0, 0.4)
		tw.chain().tween_callback(f.queue_free)

func _update_water_stream(p: Vector2) -> void:
	water_stream.visible = true
	var top := gold_area.global_position.y - 130.0
	water_stream.global_position = Vector2(p.x - 13, top)
	water_stream.size = Vector2(26, maxf(24.0, p.y - top))

# ---- płynne znikanie/pojawianie (nic nie znika skokowo) ----
func _fade_hide(n: CanvasItem, dur := 0.3) -> void:
	if n == null or not n.visible:
		return
	var tw := create_tween()
	tw.tween_property(n, "modulate:a", 0.0, dur)
	tw.tween_callback(func():
		if is_instance_valid(n):
			n.visible = false
			n.modulate.a = 1.0
	)

func _fade_in_layer(layer: CanvasLayer, dur := 0.25) -> void:
	if layer == null:
		return
	var kids: Array = []
	for c in layer.get_children():
		if c is CanvasItem:
			kids.append(c)
	for c in kids:
		c.modulate.a = 0.0
	layer.visible = true
	var tw := create_tween()
	tw.set_parallel(true)
	for c in kids:
		tw.tween_property(c, "modulate:a", 1.0, dur)

func _fade_hide_layer(layer: CanvasLayer, dur := 0.3, on_done := Callable()) -> void:
	if layer == null or not layer.visible:
		if on_done.is_valid():
			on_done.call()
		return
	var kids: Array = []
	for c in layer.get_children():
		if c is CanvasItem:
			kids.append(c)
	var tw := create_tween()
	tw.set_parallel(true)
	for c in kids:
		tw.tween_property(c, "modulate:a", 0.0, dur)
	tw.chain().tween_callback(func():
		layer.visible = false
		for c in kids:
			if is_instance_valid(c):
				c.modulate.a = 1.0
		if on_done.is_valid():
			on_done.call()
	)

func _try_pick_nugget(p: Vector2) -> void:
	var best: Node = null
	var best_d := 100.0
	for b in nugget_buttons:
		if not is_instance_valid(b):
			continue
		var c: Vector2 = b.global_position + b.size * 0.5
		var d := c.distance_to(p)
		if d < best_d:
			best_d = d
			best = b
	if best != null:
		_on_nugget(best)

func _on_nugget(b) -> void:
	if not is_instance_valid(b):
		return
	if b.has_meta("pulse"):
		var pt = b.get_meta("pulse")
		if pt is Tween and pt.is_valid():
			pt.kill()
	GameState.add_raw_gold(_nuggets_value)
	_nuggets_left -= 1
	_toast("+%.1f g" % _nuggets_value, Color(1, 0.9, 0.4))
	var pos: Vector2 = b.global_position + b.size * 0.5
	nugget_buttons.erase(b)
	var ft := create_tween()
	ft.tween_property(b, "modulate:a", 0.0, 0.2)
	ft.tween_callback(b.queue_free)
	_flash(pos, Color(1, 0.9, 0.3))
	if _nuggets_left <= 0:
		await get_tree().create_timer(0.25).timeout
		_on_pick_done()

func _on_pick_done() -> void:
	if state != S.ZOOM_PICK:
		return
	if _batch_kind == "fake":
		# fałszywy alarm — brak złota, brak sprzedaży, wracamy do kopania
		_clear_nuggets()
		done_button.visible = false
		_set_state(S.IDLE)
		_fade_hide_layer(zoom_layer, 0.3)
		return
	# odzysk przeoczonych grudek przez stół
	if _nuggets_left > 0:
		var rec := _nuggets_left * _nuggets_value * GameState.pick_recovery()
		if rec > 0.0:
			GameState.add_raw_gold(rec)
			_toast("Stół odzyskał fines: %.1f g" % rec, Color(0.8, 0.9, 0.6))
	_clear_nuggets()
	done_button.visible = false
	_set_state(S.IDLE)
	_fade_hide_layer(zoom_layer, 0.3, func(): _open_sell())  # zoom znika płynnie, potem sprzedaż

# =============================================================
#  LOOT POPUP (części)
# =============================================================
func _show_loot_popup() -> void:
	_set_state(S.POPUP)
	var part := GameState.roll_part()
	var rcol: Color = part.rarity_color
	popup_layer.visible = true
	_clear_children_layer(popup_layer)

	# przezroczysty łapacz inputu (blokuje kliknięcia w grę, ale NIE zasłania ekranu)
	var catcher := Control.new()
	catcher.position = Vector2.ZERO
	catcher.size = Vector2(1080, 1920)
	catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	popup_layer.add_child(catcher)

	# karta u GÓRY ekranu (pod banerem), kolor ramki = rzadkość
	var box := Panel.new()
	box.position = Vector2(40, 280)
	box.size = Vector2(1000, 300)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.13, 0.12, 0.11, 0.97)
	sb.set_corner_radius_all(18)
	sb.set_border_width_all(6)
	sb.border_color = rcol
	box.add_theme_stylebox_override("panel", sb)
	popup_layer.add_child(box)

	# pasek rzadkości
	var rar := _mk_label("★ %s CZĘŚĆ" % part.rarity.to_upper(), 30, rcol)
	rar.position = Vector2(70, 296); rar.size = Vector2(700, 40)
	popup_layer.add_child(rar)

	# nazwa części + MASZYNA
	var nm := _mk_label("%s  —  %s" % [part.name, part.machine], 38, Color.WHITE)
	nm.position = Vector2(70, 346); nm.size = Vector2(900, 50)
	popup_layer.add_child(nm)

	# efekt
	var eff := _mk_label(part.desc, 36, Color(0.55, 0.95, 0.65))
	eff.position = Vector2(70, 404); eff.size = Vector2(900, 48)
	popup_layer.add_child(eff)

	var buy := Button.new()
	buy.text = "KUP  $%d" % int(part.cost)
	buy.position = Vector2(70, 468); buy.size = Vector2(440, 90)
	_style_button(buy, 36)
	buy.disabled = GameState.cash < part.cost
	buy.pressed.connect(func():
		if GameState.cash >= part.cost:
			GameState.add_cash(-part.cost)
			GameState.apply_part(part)
			_toast("Zamontowano: %s" % part.desc, Color(0.6, 0.9, 0.7))
			_refresh_mine()
			_close_popup()
	)
	popup_layer.add_child(buy)

	var skip := Button.new()
	skip.text = "POMIŃ"
	skip.position = Vector2(530, 468); skip.size = Vector2(440, 90)
	_style_button(skip, 36)
	skip.pressed.connect(func(): _close_popup())
	popup_layer.add_child(skip)

func _close_popup() -> void:
	popup_layer.visible = false
	_clear_children_layer(popup_layer)
	# popup w trakcie reveal — po zamknięciu rozstrzygamy (wynik już wylosowany)
	_set_state(S.SMYRANIE)
	_resolve_reveal()

# =============================================================
#  INPUT
# =============================================================
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_pointer_down = event.pressed
		if event.pressed:
			_pointer_press(event.position)
		else:
			if state == S.ZOOM_CLEAN:
				water_cursor.visible = false
				water_stream.visible = false
	elif event is InputEventMouseMotion and _pointer_down:
		_pointer_drag(event.position, event.relative)

func _pointer_press(p: Vector2) -> void:
	_last_pointer = p
	if state == S.REVEALED:
		if glint.get_global_rect().grow(40).has_point(p):
			_begin_clean()  # tap na błysk = OCZYŚĆ
	elif state == S.ZOOM_PICK:
		_try_pick_nugget(p)  # trafianie po najbliższej grudce (niezawodne)

func _pointer_drag(p: Vector2, rel: Vector2) -> void:
	_last_pointer = p
	match state:
		S.SMYRANIE:
			_erode_soil_at(p)  # ziemia znika pod palcem, odsłania rudę
		S.ZOOM_CLEAN:
			_last_pointer = p  # czyszczenie napędza _process (trzymanie = lanie wody)

# =============================================================
#  JUICE / HELPERS
# =============================================================
func _spawn_clump(p: Vector2) -> void:
	var c := Panel.new()
	c.size = Vector2(46, 46)
	c.global_position = p - Vector2(23, 23)
	_style_panel(c, Color(0.30, 0.22, 0.13))
	add_child(c)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(c, "position:y", c.position.y + 260, 0.6)
	tw.tween_property(c, "modulate:a", 0.0, 0.6)
	tw.chain().tween_callback(c.queue_free)

func _flash(pos: Vector2, col: Color) -> void:
	var f := Panel.new()
	f.size = Vector2(90, 90)
	f.global_position = pos - Vector2(45, 45)
	_style_panel(f, col)
	# na najwyższej warstwie
	toast_layer.add_child(f)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(f, "scale", Vector2(2.2, 2.2), 0.35)
	tw.tween_property(f, "modulate:a", 0.0, 0.35)
	tw.chain().tween_callback(f.queue_free)

func _toast(msg: String, col: Color) -> void:
	var l := _mk_label(msg, 40, col)
	l.position = Vector2(140, 780)
	l.size = Vector2(800, 60)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_layer.add_child(l)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", 700, 1.1)
	tw.tween_property(l, "modulate:a", 0.0, 1.1)
	tw.chain().tween_callback(l.queue_free)

func _process(_delta: float) -> void:
	if state == S.REVEALED:
		# błysk pulsuje na hałdzie (bez ruchu) — czeka na OCZYŚĆ
		var t := Time.get_ticks_msec() / 120.0
		glint.modulate = Color(1, 1, 1, 0.55 + 0.45 * sin(t))
	elif state == S.ZOOM_CLEAN:
		_update_water_stamina(_delta)
	# odliczanie do odświeżenia kursu w popupie sprzedaży
	if sell_layer and sell_layer.visible and _price_timer:
		sell_timer_label.text = "Nowy kurs za: %.1fs" % _price_timer.time_left

# =============================================================
#  SIGNALS / REFRESH
# =============================================================
func _on_cash_changed(v: float) -> void:
	cash_label.text = "$%d" % int(round(v))
	_refresh_mine()
	_refresh_sell()
	_refresh_plots()

func _on_gold_changed(v: float) -> void:
	gold_label.text = "● %.1f g" % v
	sell_button.disabled = v <= 0.0
	_refresh_sell()

func _on_price_changed(v: float) -> void:
	var arrow := "▲" if v >= _last_price else "▼"
	var col := Color(0.5, 0.95, 0.5) if v >= _last_price else Color(0.95, 0.5, 0.5)
	price_label.text = "%s $%d/g" % [arrow, int(round(v))]
	price_label.add_theme_color_override("font_color", col)
	_last_price = v
	_refresh_sell()

func _on_goal_changed(progress: float, target: float) -> void:
	if goal_bar:
		goal_bar.max_value = target
		goal_bar.value = min(progress, target)
	if goal_label:
		goal_label.text = "%.1f g / %d g" % [progress, int(target)]

func _on_sell() -> void:
	if GameState.raw_gold <= 0.0:
		return
	var earned := GameState.sell_all()
	_toast("Sprzedano za $%d" % int(round(earned)), Color(0.5, 0.95, 0.5))

func _on_upgrade_part(m: String, key: String) -> void:
	if GameState.is_locked(m, key):
		return
	if GameState.upgrade_part(m, key):
		_toast("Ulepszono: %s" % GameState.part_display_name(m, key), Color(0.7, 0.85, 1.0))
		_show_machine_detail(m)  # odśwież widok

func _refresh_hud() -> void:
	cash_label.text = "$%d" % int(round(GameState.cash))
	gold_label.text = "● %.1f g" % GameState.raw_gold
	price_label.text = "▲ $%d/g" % int(round(GameState.price))
	sell_button.disabled = GameState.raw_gold <= 0.0
	_on_goal_changed(GameState.plot_progress, GameState.plot_goal)

func _refresh_mine() -> void:
	if mine_layer == null or not mine_layer.visible:
		return
	if mine_detail_box.visible and current_machine != "":
		_show_machine_detail(current_machine)
	elif mine_list_box.visible:
		_show_machine_list()

# ---- UI factory ----
func _mk_label(txt: String, sz: int, col: Color) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _style_panel(p: Panel, col: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	p.add_theme_stylebox_override("panel", sb)

func _style_button(b: Button, sz: int) -> void:
	b.add_theme_font_size_override("font_size", sz)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

# TextureRect z gwarantowanym rozmiarem (expand_mode PRZED size, inaczej size klamruje do tekstury)
func _texrect(tex: Texture2D, sz: Vector2, stretch: int = TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var t := TextureRect.new()
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.custom_minimum_size = Vector2.ZERO
	t.stretch_mode = stretch
	t.texture = tex
	t.size = sz
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

func _make_chip(x: float, w: float, col: Color) -> Label:
	var p := Panel.new()
	p.position = Vector2(x, 18)
	p.size = Vector2(w, 68)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.14, 0.13, 0.12, 0.92)
	sb.set_corner_radius_all(22)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.32, 0.30, 0.26)
	p.add_theme_stylebox_override("panel", sb)
	add_child(p)
	var l := _mk_label("", 34, col)
	l.position = Vector2(14, 8)
	l.size = Vector2(w - 28, 52)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	p.add_child(l)
	return l

func _style_progress(pb: ProgressBar, fill: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.06, 0.05, 0.05, 0.85)
	bg.set_corner_radius_all(10)
	pb.add_theme_stylebox_override("background", bg)
	var fg := StyleBoxFlat.new()
	fg.bg_color = fill
	fg.set_corner_radius_all(10)
	pb.add_theme_stylebox_override("fill", fg)

func _style_industrial_button(b: Button, sz: int) -> void:
	b.add_theme_font_size_override("font_size", sz)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_color_override("font_color", Color(0.15, 0.12, 0.06))
	b.add_theme_color_override("font_hover_color", Color(0.15, 0.12, 0.06))
	b.add_theme_color_override("font_pressed_color", Color(0.15, 0.12, 0.06))
	b.add_theme_color_override("font_disabled_color", Color(0.35, 0.30, 0.22))
	# emaliowana płyta: żółty fill + ciemna metalowa ramka
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.92, 0.72, 0.12)
	normal.set_corner_radius_all(18)
	normal.set_border_width_all(8)
	normal.border_color = Color(0.20, 0.18, 0.14)
	var hover := normal.duplicate()
	hover.bg_color = Color(0.98, 0.80, 0.20)
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.80, 0.62, 0.10)
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.45, 0.40, 0.28)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("disabled", disabled)
	# nity w rogach + górny rozbłysk (dzieci rysowane na przycisku)
	var s := b.size
	for corner in [Vector2(22, 22), Vector2(s.x - 44, 22), Vector2(22, s.y - 44), Vector2(s.x - 44, s.y - 44)]:
		var rivet := Panel.new()
		rivet.position = corner
		rivet.size = Vector2(22, 22)
		var rsb := StyleBoxFlat.new()
		rsb.bg_color = Color(0.20, 0.18, 0.14)
		rsb.set_corner_radius_all(11)
		rivet.add_theme_stylebox_override("panel", rsb)
		rivet.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(rivet)
	var hl := ColorRect.new()
	hl.color = Color(1, 1, 1, 0.20)
	hl.position = Vector2(44, 16)
	hl.size = Vector2(s.x - 88, 20)
	hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(hl)

func _clear_children(node: Node) -> void:
	for c in node.get_children():
		c.queue_free()

func _clear_children_layer(layer: CanvasLayer) -> void:
	for c in layer.get_children():
		c.queue_free()

func _clear_nuggets() -> void:
	for b in nugget_buttons:
		if is_instance_valid(b):
			if b.has_meta("pulse"):
				var pt = b.get_meta("pulse")
				if pt is Tween and pt.is_valid():
					pt.kill()
			b.queue_free()
	nugget_buttons.clear()
