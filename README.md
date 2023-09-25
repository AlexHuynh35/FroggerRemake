# Remake Project

**DUE October 29th by 11:59PM**

**WIP October 2nd by lab**

You and your partner will study a classic arcade/early-computer/atari
game by remaking it in TIC-80. You do not have to recreate every
aspect of the original game, but your remake should capture the
essence of the original game. Be mindful of taking advantage (or
rebeling against) of TIC-80's affordances, in other words, what
aspects of the original game does TIC-80 make it easy to recreate.


You can choose any video game before 1986, but the more obscure the
better. Moreover, you are prohibited from doing Pong, Snake or
Breakout (however classic those games might be, they've been remade to
death!).

## Learning Objectives

- understand what makes a classic game special by distilling it to its essence;
- create a **working** reimaginiation of the game on TIC-80 in Lua;
- think and write critically about your remake.

## Deliverable

Submit your write-up on GitHub as a
[`README.md`](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax).
Your writeup should be about 1024 words, it should read clearly and
look nice. You will present your work during the lab period using a
few slides, a play-test session, and a demonstration.  You should also
include your TIC-80 game as a lua file and a collection of HTML files.

```console
unix:~$ cd remake
unix:~$ tic80 --fs .
tic-80:~$ save remake.lua
tic-80:~$ load remake.lua
tic-80:~$ export html remake.zip
unix:~$ unzip remake.zip -d game
```
