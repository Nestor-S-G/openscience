/**
 * Admin debug component used to set debug options
 */

import React, { Component } from "react";
import { Row, FormCheck } from "react-bootstrap";
import { withRouter } from "react-router-dom";
import { connect } from "react-redux";
import {
    disable_speed_debug,
    enable_speed_debug,
} from "../../redux/debug/debugActions";

class DebugPanel extends Component {
    state = {
        speed_debug: false,
    };

    componentDidMount() {
        const { speed_debug } = this.props.debug;
        this.setState({
            speed_debug,
        });
    }

    handleToggleSpeedDebug = () => {
        const speed_debug = !this.state.speed_debug;
        if (speed_debug) this.props.enableSpeedDebug();
        else this.props.disableSpeedDebug();
        this.setState({ speed_debug });
    };

    render() {
        return (
            <>
                <Row className="mt-5">
                    <h5>Debug options</h5>
                </Row>
                <Row className="mt-2">
                    <FormCheck
                        label="Use shorter screen durations to debug quickly"
                        checked={this.state.speed_debug}
                        onChange={this.handleToggleSpeedDebug}
                    />
                </Row>
            </>
        );
    }
}

// Redux stuff
const mapStateToProps = (state) => {
    return {
        debug: state.debug,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        enableSpeedDebug: () => dispatch(enable_speed_debug()),
        disableSpeedDebug: () => dispatch(disable_speed_debug()),
    };
};

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(withRouter(DebugPanel));
