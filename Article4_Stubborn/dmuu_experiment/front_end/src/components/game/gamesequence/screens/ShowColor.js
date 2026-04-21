import React, { Component} from 'react';
import { Row } from 'react-bootstrap';
import { capitalize } from '../../../../utility/TemplateParser';
import invert from 'invert-color';

export default class ShowColor extends Component {

    state = {
        color: '',
        textColor: ''
    }

    componentDidMount()
    {
        const {colorName, color} = this.props;
        this.setState({
            color: capitalize(colorName),
            textColor: invert(color, true)
        })
    }

    render() {

        const {color, textColor} = this.state;

        return (
            <div className="mb-5">
                <Row className="justify-content-center">
                    <h1>The incoming session is:</h1>
                </Row>
                <Row 
                    className="mt-5 justify-content-center" 
                    style={{"backgroundColor": color, "color": textColor}}
                >
                    <h2>{color}</h2> 
                </Row>
            </div>
        )
    }
}
