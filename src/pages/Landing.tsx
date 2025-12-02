import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";
import { Globe, Mic, Users } from "lucide-react";

export default function Landing() {
  const scrollToFeatures = () => {
    document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <div className="min-h-screen flex flex-col">
      <header className="container mx-auto px-4 py-6 flex justify-between items-center animate-fade-in">
        <h1 className="text-2xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
          TRU Talk
        </h1>
        <Link to="/auth">
          <Button variant="outline">Sign In</Button>
        </Link>
      </header>

      <main className="flex-1 container mx-auto px-4 py-12 md:py-20">
        <div className="max-w-7xl mx-auto">
          {/* Hero Content */}
          <div className="text-center mb-16 md:mb-20">
            <h2 className="text-6xl md:text-8xl font-bold mb-8 bg-gradient-to-r from-primary via-secondary to-accent bg-clip-text text-transparent animate-fade-in leading-tight" style={{ animationDelay: '0.1s' }}>
              Connect Through Voice
            </h2>
            <p className="text-xl md:text-3xl text-foreground/80 mb-12 max-w-3xl mx-auto font-light animate-fade-in leading-relaxed" style={{ animationDelay: '0.2s' }}>
              Break language barriers with real-time voice translation. Make authentic connections worldwide.
            </p>
            <div className="flex gap-4 justify-center animate-fade-in" style={{ animationDelay: '0.3s' }}>
              <Link to="/auth">
                <Button size="lg" className="text-lg px-8 py-6 h-auto shadow-lg hover:shadow-xl transition-all">
                  Get Started
                </Button>
              </Link>
              <Button size="lg" variant="outline" className="text-lg px-8 py-6 h-auto" onClick={scrollToFeatures}>
                Try Demo
              </Button>
            </div>
          </div>

          {/* Integrated Features Grid */}
          <div className="grid md:grid-cols-3 gap-6 lg:gap-8 animate-fade-in" style={{ animationDelay: '0.4s' }}>
            <div className="group relative overflow-hidden rounded-2xl bg-card/50 backdrop-blur-sm border border-border/50 p-8 hover:border-primary/50 transition-all duration-300 hover:shadow-2xl hover:shadow-primary/10 hover:-translate-y-1">
              <div className="absolute inset-0 bg-gradient-to-br from-primary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              <div className="relative z-10">
                <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-primary to-primary/60 flex items-center justify-center mb-6 shadow-lg">
                  <Globe className="w-9 h-9 text-primary-foreground" />
                </div>
                <h4 className="text-2xl font-bold mb-3 text-foreground">Break Language Barriers</h4>
                <p className="text-muted-foreground text-base leading-relaxed">Real-time voice translation lets you connect with anyone, anywhere in the world.</p>
              </div>
            </div>

            <div className="group relative overflow-hidden rounded-2xl bg-card/50 backdrop-blur-sm border border-border/50 p-8 hover:border-secondary/50 transition-all duration-300 hover:shadow-2xl hover:shadow-secondary/10 hover:-translate-y-1">
              <div className="absolute inset-0 bg-gradient-to-br from-secondary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              <div className="relative z-10">
                <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-secondary to-secondary/60 flex items-center justify-center mb-6 shadow-lg">
                  <Mic className="w-9 h-9 text-secondary-foreground" />
                </div>
                <h4 className="text-2xl font-bold mb-3 text-foreground">Authentic Conversations</h4>
                <p className="text-muted-foreground text-base leading-relaxed">Voice-first connections create deeper, more meaningful relationships.</p>
              </div>
            </div>

            <div className="group relative overflow-hidden rounded-2xl bg-card/50 backdrop-blur-sm border border-border/50 p-8 hover:border-accent/50 transition-all duration-300 hover:shadow-2xl hover:shadow-accent/10 hover:-translate-y-1">
              <div className="absolute inset-0 bg-gradient-to-br from-accent/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              <div className="relative z-10">
                <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-accent to-accent/60 flex items-center justify-center mb-6 shadow-lg">
                  <Users className="w-9 h-9 text-accent-foreground" />
                </div>
                <h4 className="text-2xl font-bold mb-3 text-foreground">Global Community</h4>
                <p className="text-muted-foreground text-base leading-relaxed">Join thousands of people making cross-cultural connections daily.</p>
              </div>
            </div>
          </div>
        </div>
      </main>

      <section id="features" className="sr-only" aria-hidden="true"></section>

      <footer className="container mx-auto px-4 py-8 text-center text-muted-foreground">
        <p>&copy; 2025 TRU Talk. Breaking barriers through authentic conversations.</p>
      </footer>
    </div>
  );
}
