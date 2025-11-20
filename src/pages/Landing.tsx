import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";

export default function Landing() {
  return (
    <div className="min-h-screen flex flex-col">
      <header className="container mx-auto px-4 py-6 flex justify-between items-center">
        <h1 className="text-2xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
          TRU Talk
        </h1>
        <Link to="/auth">
          <Button variant="outline">Sign In</Button>
        </Link>
      </header>

      <main className="flex-1 container mx-auto px-4 flex flex-col items-center justify-center text-center">
        <h2 className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-primary via-secondary to-accent bg-clip-text text-transparent">
          Connect Through Voice
        </h2>
        <p className="text-xl md:text-2xl text-muted-foreground mb-12 max-w-2xl">
          Break language barriers with real-time voice translation. Make authentic connections worldwide.
        </p>
        <div className="flex gap-4">
          <Link to="/auth">
            <Button size="lg" className="text-lg">
              Get Started
            </Button>
          </Link>
          <Button size="lg" variant="outline" className="text-lg">
            Learn More
          </Button>
        </div>
      </main>

      <footer className="container mx-auto px-4 py-8 text-center text-muted-foreground">
        <p>&copy; 2024 TRU Talk. Breaking barriers through authentic conversations.</p>
      </footer>
    </div>
  );
}
