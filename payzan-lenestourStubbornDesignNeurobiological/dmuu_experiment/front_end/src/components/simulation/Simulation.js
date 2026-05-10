import React, { Component } from 'react';
import Probability from './Probability';
import {Container, Row, Col, Button} from 'react-bootstrap';    

const screenStates = {
    FIRST_SIM: 'first',
    SECOND_SIM: 'second',
    FINISH_SIM: 'finish'
}

export default class Simulation extends Component {

    state = {
        curState: screenStates.FIRST_SIM,
        reset_first: false,
        reset_second: false,
        firstSimNo: 1,
        secondSimNo: 1
    }

    nextState = () => 
    {
        const {FIRST_SIM, SECOND_SIM, FINISH_SIM} = screenStates;
        let {curState} = this.state;

        switch(curState)
        {
            case FIRST_SIM:
                curState = SECOND_SIM;
                break;

            case SECOND_SIM:
                curState = FINISH_SIM;
                break;

            case FINISH_SIM:
                break;

            default:
                break;
        }

        this.setState({...this.state, curState});
    }

    finishFirst = () => 
    {
        this.pauseFirst();
    }

    incrementFirst = () =>
    {
        const {firstSimNo} = this.state;
        if (firstSimNo === this.props.examples)
        {
            this.nextState();  
        }
        else
        {
            this.resetFirstSim();   
            this.setState({...this.state, firstSimNo: firstSimNo + 1})
        }
    }

    pause = (incrementFunc) =>
    {
        this.timer = setInterval(() => {
            clearInterval(this.timer);
            incrementFunc();
        }, 1000*this.props.pause);
    }

    pauseFirst = () =>
    {
        this.pause(this.incrementFirst);
    }

    incrementSecond = () =>
    {
        const {secondSimNo} = this.state;
        if (secondSimNo === this.props.examples)
        {
            this.nextState();   
        }
        else
        {
            this.resetSecondSim();   
            this.setState({...this.state, secondSimNo: secondSimNo + 1})
        }
    }

    finishSecond = () =>
    {
        this.pauseSecond();
    }

    pauseSecond = () =>
    {
        this.pause(this.incrementSecond);
    }

    showFirstSim = () =>
    {
        return (
            <Col>
                <Probability 
                    no={this.state.firstSimNo}
                    color={this.props.high_color}
                    prob={this.props.high_probability} 
                    draws={this.props.draws} 
                    finish={this.finishFirst} 
                    reset={this.state.reset_first} 
                    resetFinish={this.resetFirstFinish}
                />                
            </Col>
        );
    }
    
    showSecondSim = () =>
    {
        const {curState} = this.state;
        if (curState === screenStates.SECOND_SIM || curState === screenStates.FINISH_SIM)
        {
            return (
                    <Col>
                        <Probability
                            no={this.state.secondSimNo}
                            color={this.props.low_color}
                            prob={this.props.low_probability} 
                            draws={this.props.draws} 
                            finish={this.finishSecond} 
                            reset={this.state.reset_second} 
                            resetFinish={this.resetSecondFinish}
                        />                
                    </Col>
            );
        }

        return (<Col></Col>);
    }

    resetFirstSim = () =>
    {
        this.setState({...this.state, reset_first: true});
    }

    resetSecondSim = () =>
    {
        this.setState({...this.state, reset_second: true});
    }

    resetFirstFinish = () =>
    {
        this.setState({...this.state, reset_first: false});
    }

    resetSecondFinish = () =>
    {
        this.setState({...this.state, reset_second: false});
    }

    showButtons = () =>
    {
        const {curState} = this.state;

        if (curState === screenStates.FINISH_SIM)
        {
            return (
                <Row className="pt-5 justify-content-center">
                    <Button onClick={this.props.goback}>Proceed</Button>
                </Row>
            );
        }
        return null;
    }

    render() {
        return (
            <Container className="mt-5">
                <Row>
                    {this.showFirstSim()}
                    {this.showSecondSim()}
                </Row>
                {this.showButtons()}
            </Container>
        )
    }
}
