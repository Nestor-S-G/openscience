import * as React from "react";
import { mount } from "@cypress/react";
import FinalQuiz from "./FinalQuiz";
import { Provider } from "react-redux";
import store from "../../../redux/store";
import { setBetInCBlocks } from "../../../redux/playerStats/playerStatsActions";

function getElem(tag) {
    return `[data-test-id="${tag}"]`;
}

const DUMMY_INPUT = "dummy";

it("FinalQuiz", () => {
    const finishQuiz = cy.stub();
    cy.wrap(store).invoke("dispatch", setBetInCBlocks());
    mount(
        <Provider store={store}>
            <FinalQuiz
                finish={finishQuiz}
                low_color={"yellow"}
                high_color={"blue"}
            />
        </Provider>
    );

    cy.log("FinalQuiz Q1 Testing");
    cy.get(getElem("cy-FinalQuiz-Q1-box")).should("exist");
    cy.get(getElem("cy-FinalQuiz-Q1-toughsession")).click();
    cy.get(getElem("cy-FinalQuiz-Q1-submit"))
        .click()
        .then(() => {
            expect(finishQuiz).to.have.been.calledOnce;
            expect(finishQuiz).to.have.been.calledWithExactly({
                q1: 1,
                q2: null,
                q3: null,
                other: null,
                correct: 0,
            });
        });
    cy.get(getElem("cy-FinalQuiz-Q1-dontknow")).click();
    cy.get(getElem("cy-FinalQuiz-Q1-submit"))
        .click()
        .then(() => {
            expect(finishQuiz).to.have.been.calledTwice;
            expect(finishQuiz).to.have.been.calledWithExactly({
                q1: 3,
                q2: null,
                q3: null,
                other: null,
                correct: 0,
            });
        });
    cy.get(getElem("cy-FinalQuiz-Q1-goodsession")).click();
    cy.get(getElem("cy-FinalQuiz-Q1-submit")).click();

    cy.log("FinalQuiz Q2 Testing");
    cy.get(getElem("cy-FinalQuiz-Q2-box")).should("exist");
    cy.get(getElem("cy-FinalQuiz-Q2-no")).click();
    cy.get(getElem("cy-FinalQuiz-Q2-submit"))
        .click()
        .then(() => {
            expect(finishQuiz).to.have.been.calledThrice;
            expect(finishQuiz).to.have.been.calledWithExactly({
                q1: 2,
                q2: 2,
                q3: null,
                other: null,
                correct: 1,
            });
        });
    cy.get(getElem("cy-FinalQuiz-Q2-yes")).click();
    cy.get(getElem("cy-FinalQuiz-Q2-submit")).click();

    cy.log("FinalQuiz Q3 Testing");
    cy.get(getElem("cy-FinalQuiz-Q3-box")).should("exist");
    cy.get(getElem("cy-FinalQuiz-Q3-submit"))
        .click()
        .then(() => {
            expect(finishQuiz).to.have.been.callCount(4);
            expect(finishQuiz).to.have.been.calledWithExactly({
                q1: 2,
                q2: 1,
                q3: null,
                other: null,
                correct: 1,
            });
        });
    cy.get(getElem("cy-FinalQuiz-Q3-moremoney")).click();
    cy.get(getElem("cy-FinalQuiz-Q3-sameshapes")).click();
    cy.get(getElem("cy-FinalQuiz-Q3-random")).click();
    cy.get(getElem("cy-FinalQuiz-Q3-other")).click();
    cy.get(getElem("cy-FinalQuiz-Q3-othertext")).should("exist");
    cy.get(getElem("cy-FinalQuiz-Q3-othertext")).type(DUMMY_INPUT);
    cy.get(getElem("cy-FinalQuiz-Q3-submit"))
        .click()
        .then(() => {
            expect(finishQuiz).to.have.been.callCount(5);
            expect(finishQuiz).to.have.been.calledWithExactly({
                q1: 2,
                q2: 1,
                q3: 1234,
                other: DUMMY_INPUT,
                correct: 1,
            });
        });
});
