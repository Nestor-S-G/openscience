import React, { Component } from 'react';
import Phaser from 'phaser';
import { IonPhaser } from '@ion-phaser/react';

// Game engine
import preload from './gameengine/preload';
import create from './gameengine/create';
import update from './gameengine/update';

export default class SlotGame extends Component {
    state = {
        initialize: true,
        game : {
            scale: {
                mode: Phaser.Scale.FIT,
                width: 1024,
                height: 768
            },
            transparent: true,
            fps: {
                target: 40,
                forceSetTimeOut: true
            },
            physics: {
                default: 'arcade',
                arcade: {
                    debug: false
                }
            },
            type: Phaser.AUTO,
            scene: {
                preload: preload,
                create: create,
                update: update
            }
        }
    }    

    render() {
        const { initialize, game} = this.state
        const { spin_duration, result_duration, probability, finish, cheeky, reward, sound, high} = this.props;
        return (
            <IonPhaser 
                className="d-flex justify-content-center"
                game={game} 
                initialize={initialize}
                spin_duration={spin_duration*1000}
                result_duration={result_duration*1000}
                probability={probability} 
                result={finish} 
                cheeky={cheeky} 
                reward={`$${reward}`}
                sound={sound}
                high={high}
            />
        )
    }
}
