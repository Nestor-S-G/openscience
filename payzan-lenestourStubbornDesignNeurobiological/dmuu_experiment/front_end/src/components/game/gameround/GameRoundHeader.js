// Header to display the current round information

import React, { Component } from 'react';
import invert from 'invert-color';
import stc from 'string-to-color';

export default class GameRoundHeader extends Component {

    state = {
        backgroundColor: 'white',
        textColor: 'black'
    }

    componentDidMount()
    {
        const { color } = this.props;

        const textColor = invert(stc(color), true);

        this.setState({backgroundColor: color, textColor});
    }

    render() {

        const {backgroundColor, textColor} = this.state;

        return (
            <div className="navbar navbar-expand-sm" style={{backgroundColor, color: textColor, fontSize: "40px"}}>
                {this.props.children}
            </div>
        )
    }
}
