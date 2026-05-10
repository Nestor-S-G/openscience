import React, { Component, Fragment } from "react";
import { Container, Row, Button } from "react-bootstrap";
import { connect } from "react-redux";
import {
    completeSimulation,
    fetchInstructions,
} from "../../redux/instruction/instructionActions";
import { Redirect } from "react-router-dom";
import {
    GAME,
    INS_SIMULATION,
    getPage,
    BUTTON_SHOW_BOTH,
    BUTTON_SHOW_NEXT_ONLY,
    BUTTON_SHOW_NONE,
    BUTTON_SHOW_PREV_ONLY,
    switchPage,
    instructionButtonShow,
    NEXT_PAGE,
    PREV_PAGE,
    FIRST_PAGE,
    INS_FAQ,
} from "./InstructionOrder";

// Instructions

const KEY_CODE = 78; // N key

class Instructions extends Component {
    constructor(props) {
        super(props);
        this.props.fetchInstruction();

        this.state = {
            curPage: FIRST_PAGE,
            buttonState: BUTTON_SHOW_NEXT_ONLY,
        };
    }

    changePage = (page) => {
        const {
            simulationComplete,
            practiceComplete,
            downloadedFAQ,
        } = this.props.storeInstructions;
        const instructionState = { simulationComplete, practiceComplete, downloadedFAQ };
        const { curPage } = this.state;
        let newPage = page;

        if (page === NEXT_PAGE || page === PREV_PAGE)
            newPage = switchPage(curPage, page);

        this.setState({
            curPage: newPage,
            buttonState: instructionButtonShow(newPage, instructionState),
        });
    };

    nextPage = () => {
        this.changePage(NEXT_PAGE);
    };

    prevPage = () => {
        this.changePage(PREV_PAGE);
    };

    checkRedirected = () => {
        const { location } = this.props;
        if (location.page)
            this.changePage(location.page);
    };

    componentDidMount() {
        this.checkRedirected();
        document.addEventListener("keydown", this.keypress, false);
    }

    componentWillUnmount() {
        document.removeEventListener("keydown", this.keypress, false);
    }

    keypress = (e) => {
        if (e.keyCode === KEY_CODE) {
            this.showBothButtons();
        }
    };

    renderButtons(show) {
        const prevButton = (
            <Button className="float-left ml-5" onClick={this.prevPage}>
                Prev
            </Button>
        );
        const nextButton = (
            <Button
                className="ml-auto float-right mr-5"
                onClick={this.nextPage}
            >
                Next
            </Button>
        );

        if (show === BUTTON_SHOW_BOTH) {
            return (
                <Fragment>
                    {prevButton}
                    {nextButton}
                </Fragment>
            );
        } else if (show === BUTTON_SHOW_PREV_ONLY) {
            return prevButton;
        } else if (show === BUTTON_SHOW_NEXT_ONLY) {
            return nextButton;
        }
    }

    showBothButtons = () => {
        this.setState({ buttonState: BUTTON_SHOW_BOTH });
    };

    hideBothButtons = () => {
        this.setState({ buttonState: BUTTON_SHOW_NONE });
    };

    finishSimulation = () => {
        this.props.completeSimulation();
        this.showBothButtons();
    };

    getInsPage = () => {
        const {
            simulationComplete,
            practiceComplete,
        } = this.props.storeInstructions;
        const instructionState = { simulationComplete, practiceComplete };

        const { curPage } = this.state;

        let page = null;

        const InsPage = getPage(curPage, instructionState);

        if (curPage !== GAME) {
            let ins_props = {};
            if (curPage === INS_SIMULATION) {
                ins_props.hideBoth = this.hideBothButtons;
                ins_props.finish = this.finishSimulation;
            }
            if (curPage === INS_FAQ)
                ins_props.showBoth = this.showBothButtons;
            page = <InsPage {...ins_props} />;
        } else {
            page = <Redirect to="/game" />;
        }

        return page;
    };

    render() {
        const { textLoaded } = this.props.storeInstructions;

        const { buttonState } = this.state;

        if (!textLoaded) {
            return <span>Loading...</span>;
        }

        return (
            <Container className="d-flex flex-column justify-content-center min-vh-100">
                    <Row className="justify-content-center">
                        {this.getInsPage()}
                    </Row>
                    <Row className="pt-5 pb-5">
                        {this.renderButtons(buttonState)}
                    </Row>
            </Container>
        );
    }
}

// Redux connection
const mapStateToProps = (state) => {
    return {
        storeInstructions: state.instruction,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        fetchInstruction: () => dispatch(fetchInstructions()),
        completeSimulation: () => dispatch(completeSimulation()),
    };
};

export default connect(mapStateToProps, mapDispatchToProps)(Instructions);
