// Used for testing and prototyping
import React, { Component } from "react";
import { Route, Switch } from "react-router-dom";
import { Container } from "react-bootstrap";
// Testing
import Instructions from "./components/instructions/Instructions";
import AskPlayer from "./components/game/gameround/screens/AskPlayer";
import Cheeky from "./components/game/gameround/screens/Cheeky";
import WinScreen from "./components/game/gameround/screens/WinScreen";
import LoseScreen from "./components/game/gameround/screens/LoseScreen";
import SlotGame from "./components/game/slotgame/SlotGame";
import Probability from "./components/simulation/Probability";
import Finish from "./components/finish/Finish";
import Incoming from "./components/game/gamesequence/screens/Incoming";
import {
    INS_PRACTICE,
    INS_MCQ,
} from "./components/instructions/InstructionOrder";
import Loader from "./components/loader/Loader";
import Lottery from "./components/finish/Lottery/Lottery";
import NotFound from "./components/NotFound";
import BreakSequence from "./components/game/gamesequence/screens/Break/BreakSequence/BreakSequence";
import OddsGuessOne from "./components/game/gamesequence/screens/OddsGuess/OddsGuessOne/OddsGuessOne";
import OddsGuessTwo from "./components/game/gamesequence/screens/OddsGuess/OddsGuessTwo/OddsGuessTwo";
import GameSequence from "./components/game/gamesequence/GameSequence";
import FinalQuiz from "./components/finish/FinalQuiz/FinalQuiz";
import PreGameStrategy from "./components/intro/PreGameStrategy";
import Wager from "./components/finish/screens/Wager";
import Chance from "./components/intro/Chance";

export default class Proto extends Component {
    render() {
        return (
            <Switch>
                <Route
                    exact
                    path="/test/askplayer"
                    render={() => <AskPlayer duration="60" />}
                />
                <Route exact path="/test/cheeky" render={() => <Cheeky />} />
                <Route
                    exact
                    path="/test/lose"
                    render={() => (
                        <LoseScreen fruitOne={"apple"} fruitTwo={"banana"} />
                    )}
                />
                <Route
                    exact
                    path="/test/win"
                    render={() => (
                        <WinScreen
                            fruitOne={"apple"}
                            fruitTwo={"apple"}
                            amount={"$2"}
                        />
                    )}
                />
                <Route
                    exact
                    path="/test/finish"
                    render={() => (
                        <Finish
                            test={{}}
                            location={{
                                data: {
                                    net: 100,
                                    threshold: 140,
                                    low_color: "yellow",
                                    high_color: "blue",
                                    multiplier: 4,
                                },
                            }}
                        />
                    )}
                />
                <Route
                    exact
                    path="/test/probability"
                    render={() => (
                        <Probability
                            prob={80}
                            draws={100}
                            color="#FFFF00"
                            finish={() => console.log("Finish simulation")}
                        />
                    )}
                />
                <Route
                    exact
                    path="/test/game_debug"
                    render={() => <GameSequence debug={true} />}
                />
                <Route
                    exact
                    path="/test/game"
                    render={() => (
                        <SlotGame
                            spin_duration={3}
                            result_duration={2}
                            probability={50}
                            cheeky={true}
                            reward={2}
                            sound={true}
                            high={true}
                            finish={(win) => {
                                console.log(win);
                            }}
                        />
                    )}
                />
                <Route
                    exact
                    path="/test/mcq"
                    render={() => <Instructions location={{ page: INS_MCQ }} />}
                />
                <Route
                    exact
                    path="/test/completePractice"
                    render={() => (
                        <Instructions location={{ page: INS_PRACTICE }} />
                    )}
                />
                <Route exact path="/test/incoming" component={Incoming} />
                <Route exact path="/test/loader" component={Loader} />
                <Route
                    exact
                    path="/test/lottery"
                    render={() => (
                        <Lottery
                            prizeMoney={100}
                            finish={(win_amnt) => console.log(win_amnt)}
                        />
                    )}
                />
                <Route
                    exact
                    path="/test/break_sequence"
                    render={() => (
                        <BreakSequence time="20"/>
                    )}
                />
                <Route
                    exact
                    path="/test/odds_guess_1"
                    render={() => (
                        <OddsGuessOne
                            finish={() =>
                                console.log("Proto: Finished OddsGuessOne")
                            }
                        />
                    )}
                />
                <Route
                    exact
                    path="/test/odds_guess_2"
                    render={() => (
                        <OddsGuessTwo finish={(param) => console.log(param)} />
                    )}
                />
                <Route
                    exact
                    path="/test/finalQuiz"
                    render={() => (
                        <FinalQuiz
                            low_color="yellow"
                            high_color="blue"
                            finish={(answers) => console.log(answers)}
                        />
                    )}
                />
                <Route exact path="/test/chance" component={Chance} />
                <Route exact path="/test/pregame" component={PreGameStrategy} />
                <Route
                    exact
                    path="/test/wager"
                    render={() => (
                        <Container className="h-100">
                            <div className="d-flex flex-column justify-content-center h-100">
                                <Wager nextFunc={() => console.log("Submitted wager!")}/>
                            </div>
                        </Container>
                    )}
                />
                <Route component={NotFound} />
            </Switch>
        );
    }
}
