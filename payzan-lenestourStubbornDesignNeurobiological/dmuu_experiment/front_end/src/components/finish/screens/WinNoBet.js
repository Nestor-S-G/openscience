/**
 * Score > 0 no bet or lottery
 */
import { Component } from "react";
import { winCommon } from "./WinCommon";

export default class WinNoBet extends Component {
    render() {
        const { net, thresh, score, reward, mult, wager } = this.props;

        return winCommon(net, thresh, score, reward, mult, true, wager);
    }
}
