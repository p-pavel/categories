{-# OPTIONS --universe-polymorphism #-}
module Categories.Profunctor where

open import Level hiding (lift)
open import Data.Product
open import Function hiding (id) renaming (_∘_ to _∙_)
open import Relation.Binary hiding (_⇒_)

open import Categories.Support.PropositionalEquality
open import Categories.Support.Quotients
import Categories.Support.ZigZag
open import Categories.Operations

open import Categories.Category
open import Categories.Agda
open import Categories.Bifunctor using (Functor; Bifunctor; module Functor)
open import Categories.Bifunctor.Properties
open import Categories.Functor.Hom
open import Categories.Lan
open import Categories.Product using (Product)
open import Categories.Yoneda

open Category using (id-comm) renaming (op to _ᵒᵖ)

Profunctor : ∀ {o a} {o′ a′} → Category o a → Category o′ a′ → ∀ h → Set (suc h ⊔ a′ ⊔ o′ ⊔ a ⊔ o)
Profunctor {a = a} {a′ = a′} C D h = Bifunctor (D ᵒᵖ) C (Sets h)

_↛_ : ∀ {o a} {o′ a′} → Category o a → Category o′ a′ → Set _
_↛_ {o} {a} {o′} {a′} C D = Profunctor C D (a ⊔ a′)

id : ∀ {o a} → {C : Category o a} → Profunctor C C _
id {C = C} = Hom[ C ][-,-]

compose : ∀ {o a} {h} {o′ a′} {h′} {o″ a″} {C : Category o a} {D : Category o′ a′} {E : Category o″ a″} 
          → Profunctor D E h′ → Profunctor C D h → Profunctor C E (h ⊔ o′ ⊔ a′ ⊔ h′)
compose {o} {a} {h} {o′} {a′} {h′} {o″} {a″} {C} {D} {E} F G = record
  { F₀ = uncurry′ _⇒_
  ; F₁ = uncurry′ action
  ; identity = identity
  ; homomorphism = homomorphism
  }
  module Guts where
  Dᵒᵖ×C = Product (D ᵒᵖ) C
  Eᵒᵖ×D = Product (E ᵒᵖ) D

  _⇒ᶠ_ = curry (Functor.F₀ F)
  _⇒ᴳ_ = curry (Functor.F₀ G)

  module C = Category C
  module D = Category D
  module E = Category E
  module Eᵒᵖ = Category (E ᵒᵖ)
  module F = Functor F
  module F′ {e} = Functor (Chooseˡ {C = E ᵒᵖ}{D = D} e F)
  module F″ {d} = Functor (Chooseʳ {C = E ᵒᵖ}{D = D} d F)
  module G = Functor G
  module G′ {c} = Functor (Chooseʳ {C = D ᵒᵖ}{D = C} c G)
  module G″ {d} = Functor (Chooseˡ {C = D ᵒᵖ}{D = C} d G)

  open E using (Category-composes) renaming (_⇒_ to _⇒ᴱ_; id to idᴱ)
  open D using (Category-composes) renaming (_⇒_ to _⇒ᴰ_; id to idᴰ)
  open C using (Category-composes) renaming (_⇒_ to _⇒ᶜ_; id to idᶜ)
  open F′ using () renaming (F₁ to _ᴰ∘ᶠ_)

  _ᴳ∘ᴰ_ : ∀ {d₁ d₂ c} → (d₂ ⇒ᴳ c) → (d₁ ⇒ᴰ d₂) → (d₁ ⇒ᴳ c)
  g ᴳ∘ᴰ f = G′.F₁ f g

  open G″ using () renaming (F₁ to _ᶜ∘ᴳ_)

  _ᶠ∘ᴱ_ : ∀ {e₁ e₂ d} → (e₂ ⇒ᶠ d) → (e₁ ⇒ᴱ e₂) → (e₁ ⇒ᶠ d)
  g ᶠ∘ᴱ f = F″.F₁ f g

  .identityᶠ : ∀ {e d} {x : e ⇒ᶠ d} → idᴰ ᴰ∘ᶠ x ≣ x
  identityᶠ = ≣-app F′.identity _

  .identityᴳ : ∀ {d c} {x : d ⇒ᴳ c} → x ᴳ∘ᴰ idᴰ ≣ x
  identityᴳ = ≣-app G′.identity _

  .assocᶠ′ : ∀ {A B C D} {f : A ⇒ᴱ B} {g : B ⇒ᶠ C} {h : C ⇒ᴰ D} → (h ᴰ∘ᶠ g) ᶠ∘ᴱ f ≣ h ᴰ∘ᶠ (g ᶠ∘ᴱ f)
  assocᶠ′ = ≣-app (≣-trans (≣-trans (≣-sym F.homomorphism)
                                    (≣-cong F.F₁ (≣-sym (id-comm (Product E D)))))
                           F.homomorphism) _

  .assocᶠ : ∀ {A B C D} {f : A ⇒ᶠ B} {g : B ⇒ᴰ C} {h : C ⇒ᴰ D} → (h ∘ g) ᴰ∘ᶠ f ≣ h ᴰ∘ᶠ (g ᴰ∘ᶠ f)
  assocᶠ = ≣-app F′.homomorphism _

  .assocᴳ : ∀ {A B C D} {f : A ⇒ᴰ B} {g : B ⇒ᴰ C} {h : C ⇒ᴳ D} → (h ᴳ∘ᴰ g) ᴳ∘ᴰ f ≣ h ᴳ∘ᴰ (g ∘ f)
  assocᴳ = ≣-app (≣-sym G′.homomorphism) _

  .assocᴳ′ : ∀ {A B C D} {f : A ⇒ᴰ B} {g : B ⇒ᴳ C} {h : C ⇒ᶜ D} → (h ᶜ∘ᴳ g) ᴳ∘ᴰ f ≣ h ᶜ∘ᴳ (g ᴳ∘ᴰ f)
  assocᴳ′ = ≣-app (≣-trans (≣-trans (≣-sym G.homomorphism)
                                    (≣-cong G.F₁ (≣-sym (id-comm (Product D C)))))
                           G.homomorphism) _

  -- the 'raw' form is composable pairs of heteromorphisms
  _⇒′_ : Category.Obj E → Category.Obj C → Set (h′ ⊔ o′ ⊔ h)
  e ⇒′ c = ∃ λ d → (d ⇒ᴳ c) × (e ⇒ᶠ d)

  -- the equivalence is generated by the associative law in the
  --   comma-thing-of-some-kind of the cographs
  record _↝_ {e} {c} (z₁ z₂ : e ⇒′ c) : Set (h′ ⊔ o′ ⊔ a′ ⊔ h) where
    constructor equal
    open Σ z₁ using () renaming (proj₁ to d₁)
    open Σ z₂ using () renaming (proj₁ to d₂)
    open Σ (proj₂ z₁) using () renaming (proj₁ to x₁; proj₂ to y₁)
    open Σ (proj₂ z₂) using () renaming (proj₁ to x₂; proj₂ to y₂)
    field
      v : d₁ ⇒ᴰ d₂
      .x-eq : x₂ ᴳ∘ᴰ v ≣ x₁
      .y-eq : v ᴰ∘ᶠ y₁ ≣ y₂

  ↝-preorder : ∀ e c → Preorder _ _ _
  ↝-preorder e c = record 
    { Carrier = e ⇒′ c
    ; _≈_ = _≣_
    ; _∼_ = _↝_
    ; isPreorder = record
      { isEquivalence = ≣-isEquivalence
      ; reflexive = λ eq → ≣-subst (_↝_ _) eq refl′
      ; trans = trans′
      }
    }
    where
    refl′ : ∀ {x} → x ↝ x
    refl′ {d , x , y} = equal idᴰ identityᴳ identityᶠ

    trans′ : ∀ {i j k} → i ↝ j → j ↝ k → i ↝ k
    trans′ {d₁ , x₁ , y₁} {d₂ , x₂ , y₂} {d₃ , x₃ , y₃} 
           (equal v x-eq y-eq) (equal v′ x-eq′ y-eq′)
      = equal (v′ ∘ v)
              (let open ≣-reasoning in begin
                 x₃ ᴳ∘ᴰ (v′ ∘ v)
               ≣⟨ ≣-sym assocᴳ ⟩
                 (x₃ ᴳ∘ᴰ v′) ᴳ∘ᴰ v
               ≣⟨ ≣-cong (λ x → x ᴳ∘ᴰ v) x-eq′ ⟩
                 x₂ ᴳ∘ᴰ v
               ≣⟨ x-eq ⟩
                 x₁
               ∎)
              (let open ≣-reasoning in begin
                 (v′ ∘ v) ᴰ∘ᶠ y₁
               ≣⟨ assocᶠ ⟩
                 v′ ᴰ∘ᶠ (v ᴰ∘ᶠ y₁)
               ≣⟨ ≣-cong (λ y → v′ ᴰ∘ᶠ y) y-eq ⟩
                 v′ ᴰ∘ᶠ y₂
               ≣⟨ y-eq′ ⟩
                 y₃
               ∎)

  module ZZ {e c} = Categories.Support.ZigZag (↝-preorder e c)
  open ZZ using () renaming (Alternating to _≡′_)

  action′ : ∀ {e e′ c c′} → (e′ ⇒ᴱ e) → (c ⇒ᶜ c′) → (e ⇒′ c) → (e′ ⇒′ c′)
  action′ f g (d , x , y) = d , g ᶜ∘ᴳ x , y ᶠ∘ᴱ f

  .action′-resp-↝ : ∀ {e e′ c c′} {f : e′ ⇒ᴱ e} {g : c ⇒ᶜ c′}
                  → {z₁ z₂ : e ⇒′ c} → z₁ ↝ z₂ → action′ f g z₁ ↝ action′ f g z₂
  action′-resp-↝ (equal v x-eq y-eq) = equal v
    (≣-trans        assocᴳ′  (≣-cong (     _ᶜ∘ᴳ_ _) x-eq))
    (≣-trans (≣-sym assocᶠ′) (≣-cong (flip _ᶠ∘ᴱ_ _) y-eq))

  .action′-resp-↝-to-≡′ : ∀ {e e′ c c′} {f : e′ ⇒ᴱ e} {g : c ⇒ᶜ c′}
                        → {z₁ z₂ : e ⇒′ c} → z₁ ↝ z₂ → action′ f g z₁ ≡′ action′ f g z₂
  action′-resp-↝-to-≡′ = ZZ.disorient ∙ ZZ.slish ∙ action′-resp-↝

  .action′-resp-≡′ : ∀ {e e′ c c′} {f : e′ ⇒ᴱ e} {g : c ⇒ᶜ c′}
                   → {z₁ z₂ : e ⇒′ c} → z₁ ≡′ z₂ → action′ f g z₁ ≡′ action′ f g z₂
  action′-resp-≡′ = ZZ.minimal ZZ.setoid (action′ _ _) action′-resp-↝-to-≡′ 

  .identity′ : ∀ {e c z} → action′ (idᴱ {e}) (idᶜ {c}) z ≣ z
  identity′ {e} {c} {d , x , y} rewrite ≣-app F″.identity y
                                      | ≣-app G″.identity x = ≣-refl

  .homomorphism′ : ∀ {e e′ e″ c c′ c″} {f : e′ ⇒ᴱ e} {f′ : e″ ⇒ᴱ e′}
                                       {g : c ⇒ᶜ c′} {g′ : c′ ⇒ᶜ c″}
                                       {z : e ⇒′ c}
                 → action′ (f ∘ f′) (g′ ∘ g) z ≣ action′ f′ g′ (action′ f g z)
  homomorphism′ {f = f} {f′} {g} {g′} {z = d , x , y}
    rewrite ≣-app (F″.homomorphism {f = f} {g = f′}) y
          | ≣-app (G″.homomorphism {f = g} {g = g′}) x = ≣-refl

  abstract
    _⇒_ : Category.Obj E → Category.Obj C → Set (h′ ⊔ o′ ⊔ a′ ⊔ h)
    e ⇒ c = Quotient (e ⇒′ c) _≡′_ ZZ.is-equivalence

    ⌞_⌝ : ∀ {e c} → e ⇒′ c → e ⇒ c
    ⌞_⌝ = ⌊_⌉

    action : ∀ {e e′ c c′} → (e′ ⇒ᴱ e) → (c ⇒ᶜ c′) → (e ⇒ c) → (e′ ⇒ c′)
    action f g = qelim′ (λ z → ⌊ action′ f g z ⌉)
                        (λ pf → qdiv (action′-resp-≡′ pf))

    action-compute : ∀ {e e′ c c′} (f : e′ ⇒ᴱ e) (g : c ⇒ᶜ c′) (z : e ⇒′ c)
                     → action f g ⌞ z ⌝ ≣ ⌞ action′ f g z ⌝
    action-compute f g z = qelim-compute′ (λ pf → qdiv (action′-resp-≡′ pf))

    ⇒-ext : ∀ {e c a} {A : Set a} {f g : (e ⇒ c) → A} (eq : (x : e ⇒′ c) → f ⌞ x ⌝ ≣ g ⌞ x ⌝) → f ≣ g
    ⇒-ext = ≣-ext ∙ qequate′

  .identity : ∀ {e c} → action (idᴱ {e}) (idᶜ {c}) ≣ Function.id
  identity = ⇒-ext λ z → ≣-trans (action-compute _ _ z)
                                 (≣-cong ⌞_⌝ identity′)

  .homomorphism : ∀ {e e′ e″ c c′ c″} {f : e′ ⇒ᴱ e} {f′ : e″ ⇒ᴱ e′}
                                      {g : c ⇒ᶜ c′} {g′ : c′ ⇒ᶜ c″}
                → action (f ∘ f′) (g′ ∘ g) ≣ action f′ g′ ∙ action f g
  homomorphism = ⇒-ext λ z →
            (action-compute _ _ z)
    >trans> (≣-cong ⌞_⌝ homomorphism′)
    >trans> (≣-sym (        (≣-cong (action _ _) (action-compute _ _ z))
                    >trans> (action-compute _ _ (action′ _ _ z))))
    where
    infixr 4 _>trans>_
    _>trans>_ : ∀ {a} {A : Set a} {x y z : A} → x ≣ y → y ≣ z → x ≣ z
    _>trans>_ = ≣-trans