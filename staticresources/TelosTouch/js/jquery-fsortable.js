

$.widget("ntx.fsortable", $.ui.sortable, {
	options: {
		emptyClass: "fsortable-empty",
		existingSortable: false
	},

	_refresh: function() {
		/**
		 * Get the total size of the fsortable and the number of occupied
		 * and free slots.
		 */

		var freeSlots = $("." + this.options.emptyClass, this.element),
				items = $(this.options.items, this.element).not(freeSlots);

		this._occupied = items.length;
		this._capacity = freeSlots.length;
		this._size = this._occupied + this._capacity;

		if (!this._capacity) {
			this.element.addClass("full");
		} else {
			this.element.removeClass("full");
		}
	},

	_getFreeSpot: function(ui) {
	

		var closest;

		if (!ui || !ui.placeholder[0]) {
			// If we have no placeholder, get the last empty slot.
			closest = $("." + this.options.emptyClass + ":last", this.element);
		} else {
			// Get the empty slot closest to the placeholder.
			closest = ui.placeholder.nextAll("." + this.options.emptyClass + ":first");
			if (!closest.length) {
				closest = ui.placeholder.prevAll("." + this.options.emptyClass + ":first");
			}
		}
		if (closest.length) {
			return closest;
		}

		// No empty slots.
		return null;
	},

	_removeFreeSpot: function(_inst) {
		var inst = _inst || this;
		inst._spot.remove();
		inst._spot = null;
		inst.element.sortable("refresh");

		// Update the capacities.
		inst._capacity--;
		inst._occupied++;

		if (inst._capacity === 0) {
			inst.element.addClass("full");
		}
	},

	_create: function() {
		var that = this;

		this.element.addClass("fsortable");

		// Prevent sorting on empty slots.
		// Make sure to not overwrite existing options.
		if (!this.options.existingSortable) {
			this.options.cancel += ", ." + this.options.emptyClass;

			// Initialize new sortable plugin passing in all options.
			this.element.sortable(this.options);
		} else {
			this.options.cancel = this.element.sortable("option", "cancel");
			this.options.cancel += ", ." + this.options.emptyClass;

			// Pass our options to existing sortable.
			this.element.sortable("option", this.options);
		}

		this._refresh();

		this._outside = false;
		this._connected = false;

		// Bind special listeners.
		this.element.on("sortactivate", function(e, ui) {
		

			if (!ui.sender || ui.sender[0] !== this) {
				that._outside = true;
			}
		});

		this.element.on("sortdeactivate", function() {
			that._outside = false;

			
			if (that._spot) {
				if (that._connected) {
					// The item bame back to us, remove the spot.
					that._spot.remove();

					// Don't forget to update capacities.
					that._capacity--;
					that._occupied++;
				} else {
					// The item dropped outside, show the spot.
					that._spot.show();
				}

				that._spot = null;
			}

			that._connected = false;
		});

		this.element.on("sortover", function(e, ui) {
			

			// If we've already hidden a free spot, don't do it again.
			if (that._spot) {
				return;
			}

			if (that._outside === true) {
					that._spot = that._getFreeSpot(ui);

					// TODO: if _spot is null, bad stuff has happened, throw an error?
					// or figure out how to gracefully cancel a sort

				$(this).one("sortchange.fs", function() {
					that._spot.hide();
				});
			}
		});

		this.element.on("sortreceive", function() {
			// If we need to remove a free spot, do it now and refresh the sortable.
			if (that._spot) {
				that._removeFreeSpot();
			}
		});

		this.element.on("sortout", function(e, ui) {
			
			$(this).off("sortchange.fs");

			that.previous = ui.placeholder.next();
			if (!that.previous.length) {
				that.previous = null;
			}
		});

		$(document).on("sortover", ".ui-sortable", function(e, ui) {
			

			// Ignore if the event triggered on us.
			if (this === that.element[0]) return;

			// Ignore if the item didn't come from us.
			if (!ui.sender || ui.sender[0] !== that.element[0]) return;

			var inst = ui.sender.data(that.widgetFullName),
					o = $("<div></div>").addClass(that.options.emptyClass);

			if (!inst.previous) {
				o.appendTo(inst.element);
			} else {
				o.insertBefore(inst.previous);
			}

			// Refresh the sortable.
			//inst.refresh();
			ui.sender.sortable("refresh");

			// Update capacities.
			if (!inst._connected) {
				inst._capacity++;
				inst._occupied--;
			}

			// Prepare the sender in case the item returns to them.
			inst._outside = true;
			inst._connected = true;
			if (inst._spot) {
				inst._spot.remove();
				inst._spot = null;
			}

			inst.element.removeClass("full");
		});
	},

	_destroy: function() {
		this.element.removeClass("fsortable full");
		if (!this.options.existingSortable) {
			this.element.sortable("destroy");
		}
	},

	refresh: function() {
		this._refresh();
		this.element.sortable("refresh");
	},

	size: function() {
		return this._size;
	},

	capacity: function() {
		return this._capacity;
	},

	occupied: function() {
		return this._occupied;
	}
});

