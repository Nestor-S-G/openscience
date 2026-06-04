import React, { Component, Fragment } from 'react';
import {Row, Col, Container, Button, Image} from 'react-bootstrap';
import templateParser from '../../../utility/TemplateParser';
import Simulation from '../../simulation/Simulation';
import { completeSimulation } from '../../../redux/instruction/instructionActions';
import { connect } from 'react-redux';

const TEXT_FILE = "simulation.json";

const NORMAL_STATE = "normal_state";
const SIM_STATE = "simulation_state";

class InsSimulation extends Component {

    constructor(props)
    {
        super(props);

        const { title, para1, para2 } = this.props.text;

        const {color, probability} = this.props.config.params;

        const {low_name, high_name} = color;

        const {low, high} = probability;

        const high_probability = high*100;

        const low_probability = low*100;

        this.state = {
            title, 
            para1: templateParser(para1, {high_color: high_name, high_probability}),
            para2: templateParser(para2, {low_color: low_name, low_probability}),
            high_probability,
            low_probability,
            showProbability: false,
            curState: NORMAL_STATE
        };

    }

    enableProbability = () =>
    {
        this.setState({...this.state, curState: SIM_STATE});
        this.props.hideBoth();
    }

    showInfo = () =>
    {

        const { title, para1, para2, curState } = this.state;

        if (curState === NORMAL_STATE)
        {
            return (
                <Container className="mt-5">
                    <Row className="mt-5 justify-content-center">
                        <h1>{title}</h1>
                    </Row>
                    <Col>
                        <Row>
                            <Col>
                                <p>{para1}</p>
                            </Col>
                            <Col className="d-flex flex-column justify-content-center">
                                <p>{para2}</p>
                            </Col>
                        </Row>
                        <Row>
                            <Col>
                                <Image src={process.env.PUBLIC_URL + "/assets/high_probability.png"} />
                            </Col>
                            <Col>
                                <Image src={process.env.PUBLIC_URL + "/assets/low_probability.png"} />
                            </Col>
                        </Row>
                    </Col>
                    <Row className="mt-5 justify-content-center" >
                        <Button onClick={this.enableProbability}>Probability Explained</Button>
                    </Row>
                </Container>
            )
        }
    }

    goback = () => 
    {
        this.setState({...this.state, curState: NORMAL_STATE});
        this.props.completeSimulation();
        this.props.finish();
    }

    showSimulation = () =>
    {
        const { curState, low_probability, high_probability } = this.state;
        if (curState === SIM_STATE)
        {
            const {color, simulation} = this.props.config.params;

            return (
                <Simulation 
                    examples={simulation.examples}
                    pause={simulation.pause}
                    low_color={color.low_probability}
                    high_color={color.high_probability}
                    low_probability={low_probability} 
                    high_probability={high_probability} 
                    draws={100}
                    goback={this.goback}
                />
            ) ;
        }
    }
    

    render() {

        return (
            <Fragment>
                {this.showInfo()}
                {this.showSimulation()}
            </Fragment>
        )
    }
}

// Redux
const mapStateToProps = (state) => {
    return {
        config: state.config.config,
        text: state.instruction.text[TEXT_FILE]
    }
}

const mapDispatchToProps = (dispatch) => {
    return {
        completeSimulation: () => dispatch(completeSimulation())
    }
}

export default connect(mapStateToProps, mapDispatchToProps)(InsSimulation);