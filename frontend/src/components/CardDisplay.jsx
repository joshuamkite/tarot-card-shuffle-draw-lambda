import PropTypes from 'prop-types';

const CardDisplay = ({ drawnCards, message, onReset }) => {
    return (
        <div className="card-display">
            <h1>Tarot Draw Result</h1>
            <div className="cards-container">
                {drawnCards.map((card, index) => (
                    <div key={index} className="card">
                        <p className="card-name">
                            {card.number} {card.nameSuit} {card.reversed}
                        </p>
                        <img
                            src={card.image}
                            alt={`${card.number} ${card.nameSuit}`}
                            className={card.reversed ? 'reversed' : ''}
                        />
                    </div>
                ))}
            </div>
            {message && <p className="message">{message}</p>}
            <button onClick={onReset} className="reset-button">
                Back to Home
            </button>
        </div>
    );
};

CardDisplay.propTypes = {
    drawnCards: PropTypes.arrayOf(
        PropTypes.shape({
            number: PropTypes.string.isRequired,
            nameSuit: PropTypes.string.isRequired,
            reversed: PropTypes.string,
            image: PropTypes.string.isRequired,
        })
    ).isRequired,
    message: PropTypes.string,
    onReset: PropTypes.func.isRequired,
};

export default CardDisplay;