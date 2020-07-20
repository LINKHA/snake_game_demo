import {Player} from './player';

import {Socket} from 'phoenix';

const PLAYER_SPEED = {
    SPEED: 3
};

export class Game {
    // this.player 本客户端的player  
    // this.snake 本客户端的snake

    // envlogMsg //全局log
    constructor(engine, nickname) {
        this.players = [];
        this.bullets = [];
        this.foods;
        this.playerId = null;
        this.nickname = nickname;
        this.engine = engine;
        this.ready = false;
    }

    start() {
        //更新左上角rank 分数 test
        this.channel.on('update_ranking', payload => {
            let rankingText = payload.ranking
                .map(position => {
                    if(position.player_id == this.playerId) {
                        return `${position.nickname.substring(0, 8)}: ${position.value} (me)`;
                    } else {
                        return `${position.nickname.substring(0, 8)}: ${position.value}`;
                    }
                }).join('\n');

            this.ranking.text = rankingText;
        });

        //判断是否撞墙
        this.channel.on('against_player', payload => {
            if(this.playerId == payload.player_id) {
                this.players[payload.player_id].alpha = 0;
            }
        });

        //移动玩家
        this.channel.on('update_players', payload => {
            payload.players.forEach(player => {

                if(!this.players[player.id] && player.id != this.playerId) {
                    this.players[player.id] = this._createShip(player.x, player.y, 'snakehead2', player.rotation);
                    this.players[player.id].text = this._createNicknameText(player.x, player.y-25, player.nickname.substring(0, 8));
                }
////////////////////////////////////////////////////////////////////////////////////////////
                if (player.id == this.playerId) {
                    this.pleyerSprite.x = player.x;
                    this.pleyerSprite.y = player.y;
                    this.pleyerSprite.angle = this._setPlayerAngle(player.deltaX,player.deltaY);
                }
////////////////////////////////////////////////////////////////////////////////////////////

                if (player.id != this.playerId) {
                    this.players[player.id].x = player.x;
                    this.players[player.id].y = player.y;
                    this.players[player.id].angle = this._setPlayerAngle(player.deltaX,player.deltaY);

                    this.players[player.id].text.x = player.x;
                    this.players[player.id].text.y = player.y+25;
                    this.players[player.id].text.angle = this. _setPlayerAngle(player.deltaX,player.deltaY);
                }
            });

            for(let id in this.players) {
                if(!payload.players.some(p => p.id == id)) {
                    this.players[id].destroy();
                    this.players[id].text.destroy();
                    delete this.players[id];
                }
            }

            this._updatePlayersOnline();
        });

        //更新食物
        this.channel.on('update_food', payload => {

            payload.food.forEach(food => {
                if(this.foods) {
                    this.foods.x = food.value;
                    this.foods.y = food.value2;
                } else {
                    this.foods = this.engine.add.sprite(food.value, food.value2, 'food');
                    this.foods.anchor.x = 0.5;
                    this.foods.anchor.y = 0.5;
                }
            });
        });

        this.ready = true;
    }

    //加载资源,连接服务器
    preload(state) {
        this.engine.load.image('snakehead','images/snakehead_0.png');
        this.engine.load.image('snakebody','images/snakebody_0.png');

        this.engine.load.image('snakehead2','images/snakehead_1.png');
        this.engine.load.image('snakebody2','images/snakebody_1.png');

        this.engine.load.image('food', 'images/apple.png');
        this.engine.load.image('space', 'images/space2.png');
        this.engine.load.image('trophy', 'images/trophy.png');

        //在客户端创建socket 并加入到服务器中
        let socket = new Socket('/socket', { params: { nickname: this.nickname, player_id: this.playerId } });
        socket.connect();
        let channel = socket.channel('game:lobby', {});
        channel
            .join()
            .receive('ok', payload => this.playerId = payload.player_id);
        this.channel = channel;
    }

    create(state) {
        this.engine.add.tileSprite(0, 0, 600, 600, 'space');
        //设置左上角的text
        this.ranking = this.engine.add.text(38, 10, '', { font: '14px Arial', fill: '#fff' });
        this.engine.add.sprite(10, 6, 'trophy');
        this.playersOnline = this.engine.add.text(10, 550, '', { font: '14px Arial', fill: '#F4D03F' });//网络玩家数量 左下角
        
        //设置键盘按键
        this.cursors = state.input.keyboard.createCursorKeys();                     //方向键
        this.shootButton = state.input.keyboard.addKey(Phaser.KeyCode.SPACEBAR);  //发射子弹用 space

        //创建 Player
        let sprite = this._createShip(400, 50, 'snakehead', 0);
        this.pleyerSprite = sprite;
        this.player = new Player(sprite);
        this.channel.push('new_player', { x: sprite.x, y: sprite.y, deltaX: 0, deltaY: -PLAYER_SPEED.SPEED });
        
        this.start();
    }

    update(state) {
        if(this.ready) {
            this.player.update(this.engine, this.cursors, this.shootButton, this.channel);

            this._updateAlpha();
        }
    }

    _updateAlpha() {
        for(let id in this.players) {
            let player = this.players[id];

            if(player.alpha < 1) {
                player.alpha += (1 - player.alpha) * 0.2;
            } else {
                player.alpha = 1;
            }
        }
    }

    _createNicknameText(x, y, nickname) {
        return this.engine.add.text(x, y, nickname, { font: '10px Arial', fill: '#F4D03F' });
    }

    _createShip(x, y, type, rotation) {
        let sprite = this.engine.add.sprite(x, y, type);
        sprite.anchor.x = 0.5;
        sprite.anchor.y = 0.5;
        sprite.rotation = rotation

        return sprite;
    }

    _updatePlayersOnline() {
        let playersSize = Object.keys(this.players).length + 1;
        if(playersSize > 1) {
            this.playersOnline.text = `${playersSize} players online`;
        } else {
            this.playersOnline.text = `1 player online`;
        }
    }
    _setPlayerAngle(deltaX, deltaY) {
        if(deltaX == 0 && deltaY == -PLAYER_SPEED.SPEED){
            return 0;
        } else if(deltaX == PLAYER_SPEED.SPEED && deltaY == 0){
            return 90;
        } else if(deltaX == 0 && deltaY == PLAYER_SPEED.SPEED){
            return 180;
        } else if(deltaX == -PLAYER_SPEED.SPEED && deltaY == 0){
            return 270;
        } else {
            return 0;
        } 
    }
}
