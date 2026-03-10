VERSION ?= 1.0.0

# ── Windows ───────────────────────────────────────────────────────────────────
build-windows:
    powershell -ExecutionPolicy Bypass -File scripts/build.ps1 -Version $(VERSION) -Platform windows

build-windows-clean:
    powershell -ExecutionPolicy Bypass -File scripts/build.ps1 -Version $(VERSION) -Platform windows -Clean

# ── Linux ─────────────────────────────────────────────────────────────────────
build-linux:
    bash scripts/build.sh $(VERSION) linux

build-linux-clean:
    bash scripts/build.sh $(VERSION) linux true

# ── macOS ─────────────────────────────────────────────────────────────────────
build-macos:
    bash scripts/build.sh $(VERSION) darwin

build-macos-clean:
    bash scripts/build.sh $(VERSION) darwin true

# ── All ───────────────────────────────────────────────────────────────────────
build-all: build-windows build-linux build-macos

# ── Misc ──────────────────────────────────────────────────────────────────────
run:
    flutter run -d windows

pub:
    flutter pub get

clean:
    flutter clean