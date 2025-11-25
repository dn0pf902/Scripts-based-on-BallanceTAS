
```RndPress(f,op,pressval,mode)``` 随机按键

    f:随机按键f帧
    op:op=0 左右随机按键
       op=1 上下随机按键
    pressval:左右/上下随机按键值的总和，左/上按键值为-1，右/下按键值为1
    mode: 0:有随机左右/上下 1:无随机左右/上下

```RndPaperSingleRail(f,op,mid,mxdlt)``` 纸球单轨随机按键


    f:随机按键f帧
    op:op=0 左右随机按键
    mid:单轨中心坐标
    mxdlt：最大允许的球到单轨中心的偏移量（默认0.3）

```RndPaperConcaveFloor(f,limL,limR,mode,DIR)``` 纸球凹路面随机按键


    f:随机按键f帧
    DIR:DIR=0 左右随机按键
        DIR=1 上下随机按键

    limL:凹路面左/下边界
    limR:凹路面右/上边界
    mode:mode=0:左右晃
         mode 1:走单边
```RndPaperFlatFloor(f,limL,limR,limpos,DIR)```纸球平路面随机按键

    f:随机按键f帧
    DIR:DIR=0 左右随机按键
        DIR=1 上下随机按键

    limL:平路面左/下边界
    limR:平路面右/上边界

    limpos：当f=0时启用，向走的方向的坐标达到limpos时停止