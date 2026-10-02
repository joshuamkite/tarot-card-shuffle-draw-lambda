import { useState } from 'react'
import './App.css'
import CardDisplay from './components/CardDisplay'
import LicensePage from './components/LicensePage'
import OptionsForm from './components/OptionsForm'
import { drawCards } from './services/api'

function App() {
  const [currentView, setCurrentView] = useState('options') // 'options', 'results'
  const [drawnCards, setDrawnCards] = useState([])
  const [message, setMessage] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState(null)
  const [showLicense, setShowLicense] = useState(false)

  const handleDraw = async (deckSize, deckReverse, numCards) => {
    setIsLoading(true)
    setError(null)

    try {
      const result = await drawCards(deckSize, deckReverse, numCards)
      setDrawnCards(result.drawnCards || [])
      setMessage(result.message || '')
      setCurrentView('results')
    } catch (err) {
      setError(err.message || 'Failed to draw cards. Please try again.')
      console.error('Draw error:', err)
    } finally {
      setIsLoading(false)
    }
  }

  const handleReset = () => {
    setCurrentView('options')
    setDrawnCards([])
    setMessage('')
    setError(null)
  }

  const toggleLicense = () => {
    setShowLicense(!showLicense)
  }

  return (
    <div className="app">
      {error && (
        <div className="error-banner">
          <p>{error}</p>
          <button onClick={() => setError(null)}>Dismiss</button>
        </div>
      )}

      {currentView === 'options' && (
        <OptionsForm onDraw={handleDraw} isLoading={isLoading} />
      )}

      {currentView === 'results' && (
        <CardDisplay
          drawnCards={drawnCards}
          message={message}
          onReset={handleReset}
        />
      )}

      <footer>
        <div className="footer-buttons">
          <a
            href="https://joshuakite.co.uk/web-applications.html"
            target="_blank"
            rel="noopener noreferrer"
            className="footer-button"
          >
            Visit Website
          </a>
          <button
            type="button"
            onClick={toggleLicense}
            className="footer-button"
          >
            {showLicense ? 'Hide License' : 'Show License'}
          </button>
          <a
            href="https://github.com/joshuamkite/tarot-card-shuffle-draw-lambda"
            target="_blank"
            rel="noopener noreferrer"
            className="footer-button"
          >
            View Source
          </a>
        </div>
      </footer>

      {showLicense && <LicensePage onClose={toggleLicense} />}
    </div>
  )
}

export default App
