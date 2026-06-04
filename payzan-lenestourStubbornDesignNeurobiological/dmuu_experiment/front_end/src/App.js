import React, { Component } from "react";
import {
    HashRouter as Router,
    Switch,
    Route,
    Redirect,
} from "react-router-dom";
import { connect } from "react-redux";
import Instructions from "./components/instructions/Instructions";
import LandingPage from "./components/intro/LandingPage";
import GameSequence from "./components/game/gamesequence/GameSequence";
import Finish from "./components/finish/Finish";
import IDPage from "./components/intro/IDPage";
import Simulation from "./components/simulation/Simulation";
import Config from "./components/admin/Config";
import Proto from "./Proto";
import Admin from "./components/admin/Admin";
import Loader from "./components/loader/Loader";
import Demographic from "./components/intro/Demographic";
import ConfigLoader from "./backend_interface/configLoader/configLoader";
import "./App.css";
import Experiments from "./components/admin/Experiments";
import CheckConnection from "./components/CheckConnection";
import PreGameStrategy from "./components/intro/PreGameStrategy";
import Questionnaire from "./components/questionnaire/Questionnaire";
import Chance from "./components/intro/Chance";

const PrivateRoute = ({
    component: Component = null,
    render: Render = null,
    isLogin,
    ...rest
}) => {
    return (
        <Route
            {...rest}
            render={(props) =>
                isLogin ? (
                    Render ? (
                        Render(props)
                    ) : Component ? (
                        <Component {...props} />
                    ) : null
                ) : (
                    <Redirect to="/" />
                )
            }
        />
    );
};

class App extends Component {
    componentDidMount() {
        this.configLoader = new ConfigLoader();
        this.configLoader.loadConfig();
    }

    render() {
        if (!this.props.config.loaded) {
            return <Loader />;
        }

        return (
            <Router>
                <div className="App">
                    <Switch>
                        <Route exact path="/" component={LandingPage} />
                        <PrivateRoute
                            exact
                            path="/instructions"
                            component={Instructions}
                            isLogin={this.props.email}
                        />
                        <PrivateRoute
                            exact
                            path="/game"
                            render={(props) => (
                                <GameSequence practice={false} {...props} />
                            )}
                            isLogin={this.props.email}
                        />
                        <PrivateRoute
                            exact
                            path="/game/practice"
                            render={() => <GameSequence practice={true} />}
                            isLogin={this.props.email}
                        />
                        <PrivateRoute
                            exact
                            path="/demographic"
                            component={Demographic}
                            isLogin={this.props.email}
                        />
                        <PrivateRoute exact path="/id" component={IDPage} isLogin={this.props.email} />
                        <PrivateRoute exact path="/chance" component={Chance} isLogin={this.props.email} />
                        <PrivateRoute exact path="/pregame" component={PreGameStrategy} isLogin={this.props.email} />
                        <PrivateRoute
                            exact
                            path="/finish"
                            render={(props) => <Finish {...props} />}
                            isLogin={this.props.email}
                        />
                        <PrivateRoute
                            exact
                            path="/simulation"
                            render={(props) => <Simulation {...props} />}
                            isLogin={this.props.email}
                        />
                        <Route exact path="/admin" component={Admin} />
                        <Route
                            exact
                            path="/admin/config"
                            render={(props) => (
                                <Config
                                    {...props}
                                    updateConfig={
                                        this.configLoader.updateConfig
                                    }
                                />
                            )}
                        />
                        <Route
                            exact
                            path="/admin/experiments"
                            component={Experiments}
                        />
                        <Route
                            exact
                            path="/checkConnection"
                            component={CheckConnection}
                        />
                        <Route
                            exact
                            path="/questionnaire"
                            component={Questionnaire}
                        />
                        <Proto />
                    </Switch>
                </div>
            </Router>
        );
    }
}

const mapStateToProps = (state) => {
    return {
        config: state.config,
        email: state.stats.personal_info.email,
    };
};

export default connect(mapStateToProps)(App);
