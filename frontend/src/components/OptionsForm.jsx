import { useState } from 'react';
import PropTypes from 'prop-types';

const OptionsForm = ({ onDraw, isLoading }) => {
    const [deckSize, setDeckSize] = useState('Full Deck');
    const [deckReverse, setDeckReverse] = useState('Upright and reversed');
    const [numCards, setNumCards] = useState(8);

    const handleSubmit = (e) => {
        e.preventDefault();
        onDraw(deckSize, deckReverse, numCards);
    };

    return (
        <div className="options-form">
            <h1>Tarot Card Shuffle Draw</h1>
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="deckSize">Which cards would you like to use?</label>
                    <select
                        id="deckSize"
                        value={deckSize}
                        onChange={(e) => setDeckSize(e.target.value)}
                        disabled={isLoading}
                    >
                        <option value="Full Deck">Full Deck</option>
                        <option value="Major Arcana only">Major Arcana only</option>
                        <option value="Minor Arcana only">Minor Arcana only</option>
                    </select>
                </div>

                <div className="form-group">
                    <label htmlFor="deckReverse">Would you like to include reversed cards?</label>
                    <select
                        id="deckReverse"
                        value={deckReverse}
                        onChange={(e) => setDeckReverse(e.target.value)}
                        disabled={isLoading}
                    >
                        <option value="Upright only">Upright only</option>
                        <option value="Upright and reversed">Upright and reversed</option>
                    </select>
                </div>

                <div className="form-group">
                    <label htmlFor="numCards">How many cards would you like to draw?</label>
                    <input
                        type="number"
                        id="numCards"
                        value={numCards}
                        onChange={(e) => setNumCards(parseInt(e.target.value, 10))}
                        min="1"
                        disabled={isLoading}
                    />
                </div>

                <button type="submit" disabled={isLoading}>
                    {isLoading ? 'Drawing...' : 'Draw Cards'}
                </button>
            </form>

            <div className="info-section">
                <pre>
                    Tarot Card Shuffle Draw is a free and open-source project that
                    shuffles and returns a selection of Tarot cards. It is designed for
                    demonstration/ entertainment purposes only and should not be used as
                    a substitute for professional advice. The project is written in Go and
                    this port uses AWS Lambda with a React frontend.
                    <br />
                    <br />

                    The <a href="https://github.com/joshuamkite/tarot-card-shuffle-draw-lambda">source code is available on GitHub</a> and is licensed under the
                    GNU Affero General Public License. Copyright (C) 2024 Joshua Kite
                    <br />
                    <br />

                    <a href="https://www.joshuakite.co.uk">Visit my website</a>

                </pre>

            </div >
        </div >
    );
};

OptionsForm.propTypes = {
    onDraw: PropTypes.func.isRequired,
    isLoading: PropTypes.bool.isRequired,
};

export default OptionsForm;
