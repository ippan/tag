const { StateMachine, State } = require('./state_machine');

class WaitingState extends State {

}

class Game extends StateMachine {
    constructor(map) {
        super();
    }
}

module.exports = Game;