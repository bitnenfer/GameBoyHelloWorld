Hello World Para Game Boy
=========================

Es necesario descargar e instalar [RGBDS](https://github.com/rednex/rgbds) y colocar los binarios (rgbasm, rgblink y rgbfix) en el directorio `tools/rgbds` en la raíz del proyecto.

Los comandos para ensamblar el proyecto son:
```
rgbasm -o main.o main.asm
rgblink -o hello.gb main.o
rgbfix -p0 -v hello.gb
```

Cualquier pregunta me pueden encontrar en https://twitter.com/bitnenfer.

