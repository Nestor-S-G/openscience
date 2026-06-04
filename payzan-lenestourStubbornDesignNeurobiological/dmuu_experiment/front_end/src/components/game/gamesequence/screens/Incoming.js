import React, { Component } from 'react';
import { Image, Container, Row } from 'react-bootstrap';
import ShowColor from './ShowColor';

const AARON_NORMAL_IMG_SRC = process.env.PUBLIC_URL + "/assets/instruction_pages/aaron_reveal_win.png";
const AARON_CHEEKY_IMG_SRC = process.env.PUBLIC_URL + "/assets/instruction_pages/aaron_cheeky.png";

const LOW_REWARD_IMG_SRC = process.env.PUBLIC_URL + "/assets/low_reward_coins.png";
const HIGH_REWARD_IMG_SRC = process.env.PUBLIC_URL + "/assets/high_reward_coins.png";

export default class Incoming extends Component {
    render() {
        const { colorName, color, reward, mood, high_reward } = this.props;
        const img_src = ( mood !== 100) ? AARON_CHEEKY_IMG_SRC : AARON_NORMAL_IMG_SRC;

        const coin_img_src = high_reward ? HIGH_REWARD_IMG_SRC : LOW_REWARD_IMG_SRC;
        return (
            <Container className="h-100">
                <div className="d-flex flex-column justify-content-center h-100">
                    <Container className="pt-5">
                        <Row className="justify-content-center">
                            <ShowColor colorName={colorName} color={color}/>
                        </Row>
                        <Row className="justify-content-center align-items-center">
                            <div className="col-auto">
                                <Image src={coin_img_src}/> 
                            </div>
                            <div className="col-auto">
                                <h1>${reward}</h1>
                            </div>
                        </Row>
                        <Row className="justify-content-center pt-5">
                            <Image src={img_src}/>
                        </Row>
                    </Container>
                </div>
            </Container>
        )
    }
}
