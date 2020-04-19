# Font Install

## Source Code Pro Install

```zsh
mkdir /tmp/adodefont
cd /tmp/adodefont
wget https://github.com/adobe-fonts/source-code-pro/archive/2.010R-ro/1.030R-it.zip
unzip 1.030R-it.zip
mkdir -p ~/.fonts
cp source-code-pro-2.010R-ro-1.030R-it/OTF/*.otf ~/.fonts/
fc-cache -fv
```

## Source Han Code JP Install

Install [afdko](https://github.com/adobe-type-tools/afdko)

```zsh
python3 -m venv afdko_env
source afdko_env/bin/activate
pip install afdko
```

Install fonts

```zsh
mkdir /tmp/adodefont
cd /tmp/adodefont
git clone https://github.com/adobe-type-tools/opentype-svg.git
export PATH="$PATH:$(pwd)/opentype-svg"
git clone https://github.com/adobe-fonts/source-han-code-jp.git
cd source-han-code-jp
./commands.sh
cp ./*/*.otf ~/.fonts/
fc-cache -fv
```

deactivate

```zsh
deactivate
```

## Noto Color Emoji install

Get emoji font from https://www.google.com/get/noto/#emoji-zsye-color

```zsh
unzip NotoColorEmoji-unhinted.zip
mv NotoColorEmoji.ttf ~/.fonts
fc-cache -fv
```

Edit `~/.config/fontconfig/fonts.conf`

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
```
